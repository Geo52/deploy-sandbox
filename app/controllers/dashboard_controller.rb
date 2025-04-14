class DashboardController < ApplicationController
  def index
      request = Plaid::InstitutionsGetRequest.new({
      count: 5,
      offset: 1,
      country_codes: [ "US" ]
      })

      response = PlaidClient.institutions_get(request)
      @banks = response.institutions.first.name
  end
end
