Feature: Faction relationship Management
  As a user
  I want to manage faction relationships
  So that I can track my game data

  Scenario: Create a new faction relationship
    Given I am logged in as a user
    When I visit the new faction relationship page
    And I fill in the faction relationship form
    And I submit the form
    Then I should see the faction relationship was created

  Scenario: View a faction relationship
    Given I am logged in as a user
    And a faction relationship exists
    When I visit the faction relationship page
    Then I should see the faction relationship details
