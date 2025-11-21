Feature: Game session participant Management
  As a user
  I want to manage game session participants
  So that I can track my game data

  Scenario: Create a new game session participant
    Given I am logged in as a user
    When I visit the new game session participant page
    And I fill in the game session participant form
    And I submit the form
    Then I should see the game session participant was created

  Scenario: View a game session participant
    Given I am logged in as a user
    And a game session participant exists
    When I visit the game session participant page
    Then I should see the game session participant details
