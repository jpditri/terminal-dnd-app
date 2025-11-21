Feature: Damage log Management
  As a user
  I want to manage damage logs
  So that I can track my game data

  Scenario: Create a new damage log
    Given I am logged in as a user
    When I visit the new damage log page
    And I fill in the damage log form
    And I submit the form
    Then I should see the damage log was created

  Scenario: View a damage log
    Given I am logged in as a user
    And a damage log exists
    When I visit the damage log page
    Then I should see the damage log details
