Feature: Npc Management
  As a user
  I want to manage npcs
  So that I can track my game data

  Scenario: Create a new npc
    Given I am logged in as a user
    When I visit the new npc page
    And I fill in the npc form
    And I submit the form
    Then I should see the npc was created

  Scenario: View a npc
    Given I am logged in as a user
    And a npc exists
    When I visit the npc page
    Then I should see the npc details
