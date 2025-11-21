Feature: Ai message Management
  As a user
  I want to manage ai messages
  So that I can track my game data

  Scenario: Create a new ai message
    Given I am logged in as a user
    When I visit the new ai message page
    And I fill in the ai message form
    And I submit the form
    Then I should see the ai message was created

  Scenario: View a ai message
    Given I am logged in as a user
    And a ai message exists
    When I visit the ai message page
    Then I should see the ai message details
