Feature: Solo game state Management
  As a user
  I want to manage solo game states
  So that I can track my game data

  Scenario: Create a new solo game state
    Given I am logged in as a user
    When I visit the new solo game state page
    And I fill in the solo game state form
    And I submit the form
    Then I should see the solo game state was created

  Scenario: View a solo game state
    Given I am logged in as a user
    And a solo game state exists
    When I visit the solo game state page
    Then I should see the solo game state details
