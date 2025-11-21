Feature: Npc interaction Management
  As a user
  I want to manage npc interactions
  So that I can track my game data

  Scenario: Create a new npc interaction
    Given I am logged in as a user
    When I visit the new npc interaction page
    And I fill in the npc interaction form
    And I submit the form
    Then I should see the npc interaction was created

  Scenario: View a npc interaction
    Given I am logged in as a user
    And a npc interaction exists
    When I visit the npc interaction page
    Then I should see the npc interaction details
