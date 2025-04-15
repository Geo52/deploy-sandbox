class PlaidController < ApplicationController
  def index
      request = Plaid::InstitutionsGetRequest.new({
      count: 5,
      offset: 1,
      country_codes: [ "US" ]
      })

      response = PlaidClient.institutions_get(request)
      @banks = response.institutions.first.name
  end

  def create_link_token
    request = Plaid::LinkTokenCreateRequest.new({
      user: { client_user_id: session.id.to_s },
      client_name: "Your App Name",
      products: [ "auth", "transactions" ], 
      country_codes: [ "US" ],
      language: "en"
  })

    response = PlaidClient.link_token_create(request)
    render json: { link_token: response.link_token }
  end

  def exchange_public_token
      public_token = params[:public_token]

      begin
        exchange_request = Plaid::ItemPublicTokenExchangeRequest.new(
          public_token: public_token
        )

        exchange_response = PlaidClient.item_public_token_exchange(exchange_request)
        Rails.logger.info "Successfully exchanged token for item_id: #{exchange_response.item_id}"
        access_token = exchange_response.access_token
        # item_id = exchange_response.item_id

        # Store these securely for this user
        # current_user.update(plaid_access_token: access_token, plaid_item_id: item_id)
        session[:plaid_access_token] = access_token

        render json: { success: true }
      rescue Plaid::ApiError => e
        error_response = JSON.parse(e.response_body)
        render json: { error: error_response }, status: :bad_request
      end
  end

    def get_balance
      access_token = session[:plaid_access_token]

      if access_token.nil?
        render json: { error: "No access token found" }, status: :bad_request
        return
      end

      begin
        request = Plaid::AccountsBalanceGetRequest.new(
          access_token: access_token
        )

        balance_response = PlaidClient.accounts_balance_get(request)

        render json: {
          Balance: {
            accounts: balance_response.accounts,
            item: balance_response.item
          }
        }
      rescue Plaid::ApiError => e
        Rails.logger.error "Plaid API error: #{e.response_body}"
        error_response = JSON.parse(e.response_body)
        render json: { error: error_response }, status: :bad_request
      end
    end

    #code to retrieve simple dummy data--------------------------------
    
    def one_transaction
      # Grab the access token from session (set during public_token exchange)
      access_token = session[:plaid_access_token]
    
      # If we don't have one, return an error
      return render json: { error: "No access token" }, status: 400 unless access_token
    
      # Set date range: start 30 days ago to today
      start_date = 30.days.ago.to_date.to_s
      end_date = Date.today.to_s
    
      # Create a request object to hit Plaid's /transactions/get endpoint
      request = Plaid::TransactionsGetRequest.new(
        access_token: access_token,
        start_date: start_date,
        end_date: end_date
      )
    
      begin
        # Call Plaid's API to fetch transactions using our client
        response = PlaidClient.transactions_get(request)
    
        # Pull the first transaction from the list
        tx = response.transactions.first
    
        # Send back name, amount, and date only (cleaned-up)
        render json: {
          name: tx.name,       # e.g. "Uber"
          amount: tx.amount,   # e.g. 12.34
          date: tx.date        # e.g. "2023-12-15"
        }
    
      rescue Plaid::ApiError => e
        # If something goes wrong, return the Plaid error message
        render json: { error: JSON.parse(e.response_body) }, status: 400
      end
    end


    #--------------------------------------------------------------------------------------------------------
    ##-----------------------------------------------------------------------
    ##-----------------------------------------------------------------------
    #serious code to get monthly expenses
    #indeed, there is a lot of built in methods with plaid and ruby
    #like month(s) dates request data from plaid logic etc
    

    def monthly_expenses
  # Step 1: Get the access token for the user's linked bank account
  access_token = session[:plaid_access_token]

  # If no token was saved during linking, return an error
  return render json: { error: "No access token" }, status: 400 unless access_token

  # Step 2: Set the date range to look back 4 full calendar months (e.g., Dec - Mar)
  start_date = 4.months.ago.beginning_of_month.to_date
  end_date = Date.today

  # Step 3: Create a request to fetch transactions from Plaid
  # this is a plaid API request OBJECT
  request = Plaid::TransactionsGetRequest.new(
    access_token: access_token,
    start_date: start_date.to_s, #to string 
    end_date: end_date.to_s #to string since plaid needs dates as xx-xx-xxxx
  )

  begin
    # Step 4: Get the response with all transactions
    response = PlaidClient.transactions_get(request)
    transactions = response.transactions

    # Step 5: Create regular variables for each month
    jan_total = 0
    feb_total = 0
    mar_total = 0
    apr_total = 0

    # Step 6: Loop through each (ALL) transaction and group by calendar month
    # we only use transactions from the specific date range we set!!!!!!
    transactions.each do |tx|
      # Only count expenses (positive amounts are spending)
      next if tx.amount <= 0

      tx_month = tx.date.month  # Gives a number from 1 to 12

      if tx_month == 1
        jan_total += tx.amount
      elsif tx_month == 2
        feb_total += tx.amount
      elsif tx_month == 3
        mar_total += tx.amount
      elsif tx_month == 4
        apr_total += tx.amount
      end
    end

    # Step 7: Return results to the frontend
    render json: {
      "January" => jan_total,
      "February" => feb_total,
      "March" => mar_total,
      "April" => apr_total
    }

  rescue Plaid::ApiError => e
    render json: { error: JSON.parse(e.response_body) }, status: 400
  end
end

def monthly_income
  #get access token for users linked acount
  access_token = session[:plaid_access_token]

  # If no token was saved during linking, return an error
  return render json: { error: "No access token" }, status: 400 unless access_token

  start_date = 4.months.ago.beginning_of_month.to_date
  end_date = Date.today

  #"go look inside plaid/aka in gem file to get new instance of..." with the relevant params
  request = Plaid::TransactionsGetRequest.new(
    access_token: access_token,
    start_date: start_date.to_s,
    end_date: end_date.to_s
  )

  begin #part of begin, rescure error handling

    #get the response with all the transactions
    #PlaidClient = class/object provided by gem file
    #transactions_get = method to request transaction data
    #request holds all the required parameters to do so 
    response = PlaidClient.transactions_get(request) 
    transactions = response.transactions

    jan_income = 0
    feb_income = 0
    mar_income = 0
    apr_income = 0

    # Loop through each transaction and group by calendar month
    # transactions is an array containing all transaction info
    transactions.each do |tx|
      # Only count income (negative amounts are typically income)
      next unless tx.amount < 0 #skip this tranaction unless ammount is negative

      tx_month = tx.date.month #.month extracts numerical val of month
      #helps categoize into correct month

      #check which month the tranaxtion occured in 
      if tx_month == 1
        jan_income += tx.amount.abs #jan income += this transaction ammount (absolute value)
      elsif tx_month == 2
        feb_income += tx.amount.abs
      elsif tx_month == 3
        mar_income += tx.amount.abs
      elsif tx_month == 4
        apr_income += tx.amount.abs
      end
    end

    # Return results to the frontend
    # as key value pairs
    render json: {
      "January" => jan_income,
      "February" => feb_income,
      "March" => mar_income,
      "April" => apr_income
    }

  rescue Plaid::ApiError => e #to handle errors
    #store error details in e and send to user/front end
    render json: { error: JSON.parse(e.response_body) }, status: 400
  end
end
end


#below is just primitive logic/exposure I wished to follow
#in exploring these options along with the Plaid docs
#we learn the critical parts/syntax etc that speaks plaid

# Step 1: Get a test (sandbox) access token
# access_token = get_sandbox_access_token() //this is from plaid

# Step 2: Pick a time range
# start_date = 3 months ago
# end_date = today

# Step 3: Get all transactions for that range
# transactions = plaid.get_transactions(access_token, start_date, end_date)

# Step 4: Create variables for each month
# month1_income = 0.0
# month1_expenses = 0.0
# month2_income = 0.0
# month2_expenses = 0.0
# month3_income = 0.0
# month3_expenses = 0.0

# Step 5: Go through each transaction and add it to the right month + type
# for each transaction in transactions:
#     if transaction.date is in Month 1:
#         if transaction is income:
#             month1_income += amount
#         else:
#             month1_expenses += amount

#     repeat same logic for Month 2 and Month 3...

# Step 6: Print or return the totals
# return {
#     month1: [income, expenses],
#     month 2. . . 
# }

=begin
#real code (so far)-----------------------------
  def simple_summary
    #Step 1: use access token from plaid sandbox
    access_token = 'your-sandbox-access-token-here'

    #Step 2: Pick a monthly range
    start_date = 3.months.ago.to_date
    end_date = Date.today

      #Step 3: fetch transaction info
      # This connects to Plaid's /transactions/get API
      response = PlaidClient.transactions.get(access_token, start_date, end_date). #syntax to be studied

      #Step 4: Get/retrieve the list of transactions 
      transactions = response.transactions
      # plaid gives us info in an array 

      #Step 5: Make regular variables to store monthly summations 
      month1_income = 0.0
      month1_expenses = 0.0
      month2_income = 0.0
      month2_expenses = 0.0
      month3_income = 0.0
      month3_expenses = 0.0

      #Step 6: Loop through each transaction and classify it
      #we use conditionals for each month to sort by expense or income

 transactions.each do |tx| #where transactions are trans. objects gotten eariler from plaid 

 tx_month = tx.date.month #.month returns the month number, like 4 
        tx_amount = tx.amount

        if tx_month == 3.months.ago.month
          if tx_amount < 0   tx.transaction_type == 'income' #sometimes checks are treated as negative values 
            month1_income += tx_amount.abs #absolute value
          else
            month1_expenses += tx_amount
          end
        elsif tx_month == 2.months.ago.month
          if tx_amount < 0   tx.transaction_type == 'income'
            month2_income += tx_amount.abs
          else
            month2_expenses += tx_amount
          end
        elsif tx_month == 1.month.ago.month
          if tx_amount < 0 || tx.transaction_type == 'income'
            month3_income += tx_amount.abs
          else
            month3_expenses += tx_amount
          end

#retuen all monthly expenseses/income
=end