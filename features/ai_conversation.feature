Feature: Ai conversation Management
  As a user
  I want to manage ai conversations
  So that I can track my game data

  Scenario: Create a new ai conversation
    Given I am logged in as a user
    When I visit the new ai conversation page
    And I fill in the ai conversation form
    And I submit the form
    Then I should see the ai conversation was created

  Scenario: View a ai conversation
    Given I am logged in as a user
    And a ai conversation exists
    When I visit the ai conversation page
    Then I should see the ai conversation details
