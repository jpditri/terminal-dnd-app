Feature: Monster Management
  As a user
  I want to manage monsters
  So that I can track my game data

  Scenario: Create a new monster
    Given I am logged in as a user
    When I visit the new monster page
    And I fill in the monster form
    And I submit the form
    Then I should see the monster was created

  Scenario: View a monster
    Given I am logged in as a user
    And a monster exists
    When I visit the monster page
    Then I should see the monster details
