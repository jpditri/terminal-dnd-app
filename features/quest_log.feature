Feature: Quest log Management
  As a user
  I want to manage quest logs
  So that I can track my game data

  Scenario: Create a new quest log
    Given I am logged in as a user
    When I visit the new quest log page
    And I fill in the quest log form
    And I submit the form
    Then I should see the quest log was created

  Scenario: View a quest log
    Given I am logged in as a user
    And a quest log exists
    When I visit the quest log page
    Then I should see the quest log details
