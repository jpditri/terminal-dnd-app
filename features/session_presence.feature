Feature: Session presence Management
  As a user
  I want to manage session presences
  So that I can track my game data

  Scenario: Create a new session presence
    Given I am logged in as a user
    When I visit the new session presence page
    And I fill in the session presence form
    And I submit the form
    Then I should see the session presence was created

  Scenario: View a session presence
    Given I am logged in as a user
    And a session presence exists
    When I visit the session presence page
    Then I should see the session presence details
