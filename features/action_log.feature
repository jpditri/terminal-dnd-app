Feature: Action log Management
  As a user
  I want to manage action logs
  So that I can track my game data

  Scenario: Create a new action log
    Given I am logged in as a user
    When I visit the new action log page
    And I fill in the action log form
    And I submit the form
    Then I should see the action log was created

  Scenario: View a action log
    Given I am logged in as a user
    And a action log exists
    When I visit the action log page
    Then I should see the action log details
