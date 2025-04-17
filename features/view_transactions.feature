Feature: Viewing Transactions

  Users should be able to view recent transactions from connected accounts.

  Scenario: Viewing recent transactions
    Given I have connected a bank account
    When I visit the "Transactions" page
    Then I should see a list of my most recent transactions

  Scenario: Viewing transactions for a specific account
    Given I have multiple connected accounts
    When I select a specific bank account
    Then I should only see transactions for that account