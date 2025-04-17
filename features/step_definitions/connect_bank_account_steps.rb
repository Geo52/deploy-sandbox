Given("I am a logged-in user") do
  # Simulate a logged-in user by enabling sessions and setting a session ID
  @request = ActionDispatch::TestRequest.create
  @request.env["rack.session"] = { user_id: 1, id: "test-session-id" }
end

When("I request to create a link token") do
  @response = post "/plaid/create_link_token", headers: @request.env
  @response = ActionDispatch::TestResponse.new(@response.status, @response.headers, @response.body)
  raise "Failed to create link token" unless @response.status == 200
end

Then("I should receive a valid link token") do
  # Ensure @response is not nil and assert that the response contains a link token
  expect(@response).not_to be_nil
  expect(@response.status).to eq(200)
  expect(JSON.parse(@response.body)["link_token"]).not_to be_nil
end

Given("I have a valid public token") do
  # Set a valid public token for testing
  @public_token = "valid-public-token"
  raise "Public token is missing" if @public_token.nil?

  # Initialize the request environment if not already done
  @request ||= ActionDispatch::TestRequest.create
  @request.env["rack.session"] ||= { user_id: 1, id: "test-session-id" }
end

When("I exchange the public token") do
  # Ensure @public_token is set and not nil
  raise "Public token is missing" if @public_token.nil?

  # Call the exchange_public_token action in the controller
  @response = post "/plaid/exchange_public_token", params: { public_token: @public_token }, headers: @request.env
  @response = ActionDispatch::TestResponse.new(@response.status, @response.headers, @response.body)
  raise "Failed to exchange public token" unless @response.status == 200
end

Then("I should receive an access token") do
  # Ensure @response is not nil and assert that the response contains an access token
  expect(@response).not_to be_nil
  expect(@response.status).to eq(200), "Expected status 200 but got #{@response.status}. Response body: #{@response.body}"
  expect(JSON.parse(@response.body)["access_token"]).not_to be_nil
end

Given("I have a valid access token") do
  # Simulate a valid access token in the session
  session[:plaid_access_token] = "valid-access-token"
end

When("I request account balances") do
  get "/plaid/get_balance", headers: @request.env
  @response = ActionDispatch::TestResponse.new(response.status, response.headers, response.body)
  raise "Failed to fetch account balances" unless @response.status == 200
end

Then("I should receive a list of accounts with their balances") do
  expect(@response.status).to eq(200)
  expect(JSON.parse(@response.body)["accounts"]).not_to be_empty
end
