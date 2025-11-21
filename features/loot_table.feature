Feature: Loot table Management
  As a user
  I want to manage loot tables
  So that I can track my game data

  Scenario: Create a new loot table
    Given I am logged in as a user
    When I visit the new loot table page
    And I fill in the loot table form
    And I submit the form
    Then I should see the loot table was created

  Scenario: View a loot table
    Given I am logged in as a user
    And a loot table exists
    When I visit the loot table page
    Then I should see the loot table details
