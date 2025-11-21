Feature: Combat Management
  As a user
  I want to manage combats
  So that I can track my game data

  Scenario: Create a new combat
    Given I am logged in as a user
    When I visit the new combat page
    And I fill in the combat form
    And I submit the form
    Then I should see the combat was created

  Scenario: View a combat
    Given I am logged in as a user
    And a combat exists
    When I visit the combat page
    Then I should see the combat details
