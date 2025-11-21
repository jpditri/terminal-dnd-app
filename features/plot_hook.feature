Feature: Plot hook Management
  As a user
  I want to manage plot hooks
  So that I can track my game data

  Scenario: Create a new plot hook
    Given I am logged in as a user
    When I visit the new plot hook page
    And I fill in the plot hook form
    And I submit the form
    Then I should see the plot hook was created

  Scenario: View a plot hook
    Given I am logged in as a user
    And a plot hook exists
    When I visit the plot hook page
    Then I should see the plot hook details
