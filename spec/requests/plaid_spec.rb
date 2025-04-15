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

#we use another simple test to test our income
RSpec.describe "Plaid Monthly Income", type: :request do
  describe "GET /plaid/monthly_income" do
    it "returns an empty hash when there is no income" do
      # Simulating a request to the route
      get "/plaid/monthly_income"
      
      # Check that the response is a success
      expect(response).to have_http_status(:ok)
      
      # Parse the response JSON body
      data = JSON.parse(response.body)
      
      # Check that the data is an empty hash
      expect(data).to eq({
        "January" => 0.0,
        "February" => 0.0,
        "March" => 0.0,
        "April" => 0.0
      })
    end
  end
end