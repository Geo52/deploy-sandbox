Rails.application.routes.draw do
  # root "dashboard#index"
  root "plaid#index"
  post "plaid/create_link_token", to: "plaid#create_link_token"
  post "plaid/exchange_public_token", to: "plaid#exchange_public_token"
  get "plaid/get_balance", to: "plaid#get_balance"


  # Route to hit when we want to fetch a single transaction after linking (used in dummy retrieval single variable)
  get "plaid/one_transaction", to: "plaid#one_transaction"

  # This line VVV connects the URL /plaid/monthly_expenses to the method below
  get "plaid/monthly_expenses", to: "plaid#monthly_expenses"

  get "plaid/monthly_income", to: "plaid#monthly_income"
  # this means only respond to get requests
  # 'plaid/monthly_income' is a url path, route gets triggered if someone visits: /plaid/monthly_income
  # to: 'plaid#monthly_income' ---> controller#method in that controlelr to trigger

  get "plaid/net_worth", to: "plaid#net_worth"
end
