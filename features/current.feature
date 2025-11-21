Feature: Current Management
  As a user
  I want to manage currents
  So that I can track my game data

  Scenario: Create a new current
    Given I am logged in as a user
    When I visit the new current page
    And I fill in the current form
    And I submit the form
    Then I should see the current was created

  Scenario: View a current
    Given I am logged in as a user
    And a current exists
    When I visit the current page
    Then I should see the current details
