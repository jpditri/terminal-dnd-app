Feature: Loot table entry Management
  As a user
  I want to manage loot table entries
  So that I can track my game data

  Scenario: Create a new loot table entry
    Given I am logged in as a user
    When I visit the new loot table entry page
    And I fill in the loot table entry form
    And I submit the form
    Then I should see the loot table entry was created

  Scenario: View a loot table entry
    Given I am logged in as a user
    And a loot table entry exists
    When I visit the loot table entry page
    Then I should see the loot table entry details
