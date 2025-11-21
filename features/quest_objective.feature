Feature: Quest objective Management
  As a user
  I want to manage quest objectives
  So that I can track my game data

  Scenario: Create a new quest objective
    Given I am logged in as a user
    When I visit the new quest objective page
    And I fill in the quest objective form
    And I submit the form
    Then I should see the quest objective was created

  Scenario: View a quest objective
    Given I am logged in as a user
    And a quest objective exists
    When I visit the quest objective page
    Then I should see the quest objective details
