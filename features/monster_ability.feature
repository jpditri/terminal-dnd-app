Feature: Monster ability Management
  As a user
  I want to manage monster abilities
  So that I can track my game data

  Scenario: Create a new monster ability
    Given I am logged in as a user
    When I visit the new monster ability page
    And I fill in the monster ability form
    And I submit the form
    Then I should see the monster ability was created

  Scenario: View a monster ability
    Given I am logged in as a user
    And a monster ability exists
    When I visit the monster ability page
    Then I should see the monster ability details
