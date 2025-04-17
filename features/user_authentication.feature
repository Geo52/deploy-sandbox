Feature: User Authentication

  Users should be able to sign up, log in, and log out securely.

  Scenario: Successfully signing up
    Given I am on the sign-up page
    When I enter valid details and submit the form
    Then I should be redirected to the main dashboard
    And I should see a welcome message

  Scenario: Logging in with valid credentials
    Given I am on the login page
    When I enter correct credentials
    Then I should be redirected to the main dashboard

  Scenario: Logging out
    Given I am logged into my account
    When I click the "Logout" button
    Then I should be redirected to the login page
    And I should see a "Successfully logged out" message

  Scenario: Logging in with invalid credentials
    Given I am on the login page
    When I enter incorrect credentials
    Then I should see an error message