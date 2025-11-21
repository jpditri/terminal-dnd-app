Feature: Dungeon template Management
  As a user
  I want to manage dungeon templates
  So that I can track my game data

  Scenario: Create a new dungeon template
    Given I am logged in as a user
    When I visit the new dungeon template page
    And I fill in the dungeon template form
    And I submit the form
    Then I should see the dungeon template was created

  Scenario: View a dungeon template
    Given I am logged in as a user
    And a dungeon template exists
    When I visit the dungeon template page
    Then I should see the dungeon template details
