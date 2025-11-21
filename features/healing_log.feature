Feature: Healing log Management
  As a user
  I want to manage healing logs
  So that I can track my game data

  Scenario: Create a new healing log
    Given I am logged in as a user
    When I visit the new healing log page
    And I fill in the healing log form
    And I submit the form
    Then I should see the healing log was created

  Scenario: View a healing log
    Given I am logged in as a user
    And a healing log exists
    When I visit the healing log page
    Then I should see the healing log details
