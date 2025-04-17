Given("I am on the {string} page") do |page_name|
  visit "/#{page_name.downcase.tr(' ', '_')}"
end

When("I select {string}") do |option|
  click_link option
end

Then("I should see a chart of my spending trends") do
  expect(page).to have_css(".spending-trends-chart")
  expect(page).to have_content("Monthly Spending Overview")
end
