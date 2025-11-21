Feature: Combatant Management
  As a user
  I want to manage combatants
  So that I can track my game data

  Scenario: Create a new combatant
    Given I am logged in as a user
    When I visit the new combatant page
    And I fill in the combatant form
    And I submit the form
    Then I should see the combatant was created

  Scenario: View a combatant
    Given I am logged in as a user
    And a combatant exists
    When I visit the combatant page
    Then I should see the combatant details
