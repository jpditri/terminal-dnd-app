Feature: Session Management
  As a user
  I want to manage sessions
  So that I can track my game data

  Scenario: Create a new session
    Given I am logged in as a user
    When I visit the new session page
    And I fill in the session form
    And I submit the form
    Then I should see the session was created

  Scenario: View a session
    Given I am logged in as a user
    And a session exists
    When I visit the session page
    Then I should see the session details
