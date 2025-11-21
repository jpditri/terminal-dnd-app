Feature: Encounter monster Management
  As a user
  I want to manage encounter monsters
  So that I can track my game data

  Scenario: Create a new encounter monster
    Given I am logged in as a user
    When I visit the new encounter monster page
    And I fill in the encounter monster form
    And I submit the form
    Then I should see the encounter monster was created

  Scenario: View a encounter monster
    Given I am logged in as a user
    And a encounter monster exists
    When I visit the encounter monster page
    Then I should see the encounter monster details
