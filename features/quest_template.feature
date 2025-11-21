Feature: Quest template Management
  As a user
  I want to manage quest templates
  So that I can track my game data

  Scenario: Create a new quest template
    Given I am logged in as a user
    When I visit the new quest template page
    And I fill in the quest template form
    And I submit the form
    Then I should see the quest template was created

  Scenario: View a quest template
    Given I am logged in as a user
    And a quest template exists
    When I visit the quest template page
    Then I should see the quest template details
