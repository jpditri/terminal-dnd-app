Feature: Chat message Management
  As a user
  I want to manage chat messages
  So that I can track my game data

  Scenario: Create a new chat message
    Given I am logged in as a user
    When I visit the new chat message page
    And I fill in the chat message form
    And I submit the form
    Then I should see the chat message was created

  Scenario: View a chat message
    Given I am logged in as a user
    And a chat message exists
    When I visit the chat message page
    Then I should see the chat message details
