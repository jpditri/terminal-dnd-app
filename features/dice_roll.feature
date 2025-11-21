Feature: Dice roll Management
  As a user
  I want to manage dice rolls
  So that I can track my game data

  Scenario: Create a new dice roll
    Given I am logged in as a user
    When I visit the new dice roll page
    And I fill in the dice roll form
    And I submit the form
    Then I should see the dice roll was created

  Scenario: View a dice roll
    Given I am logged in as a user
    And a dice roll exists
    When I visit the dice roll page
    Then I should see the dice roll details
