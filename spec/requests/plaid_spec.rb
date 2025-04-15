require 'rails_helper'

# spec/requests/plaid_spec.rb
RSpec.describe "Plaid Monthly Expenses", type: :request do
  describe "GET /plaid/monthly_expenses" do
    it "returns an error if no access token is present" do
      # Makes a GET request without setting up the session
      get "/plaid/monthly_expenses"

      # Expects the controller to respond with 400 Bad Request since token is missing
      expect(response).to have_http_status(:bad_request)
    end
  end
end


RSpec.describe "Plaid Monthly Income", type: :request do
  describe "GET /plaid/monthly_income" do
    it "returns an error if no access token is present" do
      #mock a GET request to the endpoint (no session/token set)
      get "/plaid/monthly_income"

      # We expect a 400 Bad Request since token is missing
      expect(response).to have_http_status(:bad_request)
    end
  end
end