Feature: Weapon Management
  As a user
  I want to manage weapons
  So that I can track my game data

  Scenario: Create a new weapon
    Given I am logged in as a user
    When I visit the new weapon page
    And I fill in the weapon form
    And I submit the form
    Then I should see the weapon was created

  Scenario: View a weapon
    Given I am logged in as a user
    And a weapon exists
    When I visit the weapon page
    Then I should see the weapon details
