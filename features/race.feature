Feature: Race Management
  As a user
  I want to manage races
  So that I can track my game data

  Scenario: Create a new race
    Given I am logged in as a user
    When I visit the new race page
    And I fill in the race form
    And I submit the form
    Then I should see the race was created

  Scenario: View a race
    Given I am logged in as a user
    And a race exists
    When I visit the race page
    Then I should see the race details
