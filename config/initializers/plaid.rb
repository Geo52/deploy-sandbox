configuration = Plaid::Configuration.new
configuration.server_index = Plaid::Configuration::Environment["sandbox"]
configuration.api_key["PLAID-CLIENT-ID"] = ENV["PLAID_CLIENT_ID"]
configuration.api_key["PLAID-SECRET"] = ENV["PLAID_SECRET"]

api_client = Plaid::ApiClient.new(
  configuration
)

PlaidClient = Plaid::PlaidApi.new(api_client)
