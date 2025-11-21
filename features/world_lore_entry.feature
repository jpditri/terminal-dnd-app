Feature: World lore entry Management
  As a user
  I want to manage world lore entries
  So that I can track my game data

  Scenario: Create a new world lore entry
    Given I am logged in as a user
    When I visit the new world lore entry page
    And I fill in the world lore entry form
    And I submit the form
    Then I should see the world lore entry was created

  Scenario: View a world lore entry
    Given I am logged in as a user
    And a world lore entry exists
    When I visit the world lore entry page
    Then I should see the world lore entry details
