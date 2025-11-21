Feature: Faction membership Management
  As a user
  I want to manage faction memberships
  So that I can track my game data

  Scenario: Create a new faction membership
    Given I am logged in as a user
    When I visit the new faction membership page
    And I fill in the faction membership form
    And I submit the form
    Then I should see the faction membership was created

  Scenario: View a faction membership
    Given I am logged in as a user
    And a faction membership exists
    When I visit the faction membership page
    Then I should see the faction membership details
