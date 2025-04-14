class PlaidController < ApplicationController
  def index
  end

  def create_link_token
    request = Plaid::LinkTokenCreateRequest.new({
      user: { client_user_id: session.id.to_s },
      client_name: "FinTrack",
      products: [ "transactions" ],
      country_codes: [ "US" ],
      language: "en"
  })

    response = PlaidClient.link_token_create(request)
    render json: { link_token: response.link_token }
  end

  def exchange_public_token
    public_token = params[:public_token]

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
  end

  def get_balance
    access_token = session[:plaid_access_token]

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
  end

  def is_account_connected
    access_token = session[:plaid_access_token]

    if access_token.present?
      render json: { status: true }
    else
      render json: { status: false }
    end
  end
end
