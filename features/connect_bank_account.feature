Feature: Connect Bank Account
  As a user
  I want to connect my bank account
  So that I can access my financial data securely

  Scenario: Generate a link token
    Given I am a logged-in user
    When I request to create a link token
    Then I should receive a valid link token

  Scenario: Exchange public token for access token
    Given I have a valid public token
    When I exchange the public token
    Then I should receive an access token

  Scenario: Fetch account balances
    Given I have a valid access token
    When I request account balances
    Then I should receive a list of accounts with their balances
