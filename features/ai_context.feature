Feature: Ai context Management
  As a user
  I want to manage ai contexts
  So that I can track my game data

  Scenario: Create a new ai context
    Given I am logged in as a user
    When I visit the new ai context page
    And I fill in the ai context form
    And I submit the form
    Then I should see the ai context was created

  Scenario: View a ai context
    Given I am logged in as a user
    And a ai context exists
    When I visit the ai context page
    Then I should see the ai context details
