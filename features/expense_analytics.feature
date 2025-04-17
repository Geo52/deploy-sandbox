Feature: Expense Analytics

  Users should be able to view detailed insights into their spending.

  Scenario: Viewing monthly spending trends
    Given I am on the "Analytics" page
    When I select "Monthly Overview"
    Then I should see a chart of my spending trends