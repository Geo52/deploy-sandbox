Given("I am on the sign-up page") do
  visit "/signup"
end

When("I enter valid details and submit the form") do
  fill_in "Email", with: "test@example.com"
  fill_in "Password", with: "password123"
  click_button "Sign Up"
end

Then("I should be redirected to the main dashboard") do
  expect(current_path).to eq("/dashboard")
end

Then("I should see a welcome message") do
  expect(page).to have_content("Welcome to your dashboard!")
end

Given("I am on the login page") do
  visit "/login"
end

When("I enter correct credentials") do
  fill_in "Email", with: "test@example.com"
  fill_in "Password", with: "password123"
  click_button "Log In"
end

Given("I am logged into my account") do
  visit "/login"
  fill_in "Email", with: "test@example.com"
  fill_in "Password", with: "password123"
  click_button "Log In"
end

When("I click the {string} button") do |button_text|
  click_button button_text
  expect(page).to have_content("Successfully logged out") if button_text == "Logout"
end

Then("I should see a {string} message") do |message|
  expect(page).to have_content(message)
end

When("I enter incorrect credentials") do
  fill_in "Email", with: "wrong@example.com"
  fill_in "Password", with: "wrongpassword"
  click_button "Log In"
end

Then("I should be redirected to the login page") do
  expect(current_path).to eq("/login")
end

Then("I should see an error message") do
  expect(page).to have_content("Invalid email or password")
end
