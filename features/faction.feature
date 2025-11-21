Feature: Faction Management
  As a user
  I want to manage factions
  So that I can track my game data

  Scenario: Create a new faction
    Given I am logged in as a user
    When I visit the new faction page
    And I fill in the faction form
    And I submit the form
    Then I should see the faction was created

  Scenario: View a faction
    Given I am logged in as a user
    And a faction exists
    When I visit the faction page
    Then I should see the faction details
