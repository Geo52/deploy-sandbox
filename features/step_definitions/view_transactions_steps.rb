Given("I have connected a bank account") do
  # Simulate a connected bank account
  @connected_account = { id: 1, name: "Test Bank Account" }
end

When("I visit the {string} page") do |page_name|
  visit "/#{page_name.downcase.tr(' ', '_')}"
end

Then("I should see a list of my most recent transactions") do
  expect(page).to have_content("Recent Transactions")
  expect(page).to have_css(".transaction", minimum: 1)
end

Given("I have multiple connected accounts") do
  @connected_accounts = [
    { id: 1, name: "Account 1" },
    { id: 2, name: "Account 2" }
  ]
end

When("I select a specific bank account") do
  select "Account 1", from: "account_selector"
end

Then("I should only see transactions for that account") do
  expect(page).to have_content("Transactions for Account 1")
  expect(page).not_to have_content("Transactions for Account 2")
end
