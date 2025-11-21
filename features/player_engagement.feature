Feature: Player engagement Management
  As a user
  I want to manage player engagements
  So that I can track my game data

  Scenario: Create a new player engagement
    Given I am logged in as a user
    When I visit the new player engagement page
    And I fill in the player engagement form
    And I submit the form
    Then I should see the player engagement was created

  Scenario: View a player engagement
    Given I am logged in as a user
    And a player engagement exists
    When I visit the player engagement page
    Then I should see the player engagement details
