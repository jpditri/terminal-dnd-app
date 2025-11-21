Feature: Game session Management
  As a user
  I want to manage game sessions
  So that I can track my game data

  Scenario: Create a new game session
    Given I am logged in as a user
    When I visit the new game session page
    And I fill in the game session form
    And I submit the form
    Then I should see the game session was created

  Scenario: View a game session
    Given I am logged in as a user
    And a game session exists
    When I visit the game session page
    Then I should see the game session details
