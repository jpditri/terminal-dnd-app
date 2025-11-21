Feature: Vtt session Management
  As a user
  I want to manage vtt sessions
  So that I can track my game data

  Scenario: Create a new vtt session
    Given I am logged in as a user
    When I visit the new vtt session page
    And I fill in the vtt session form
    And I submit the form
    Then I should see the vtt session was created

  Scenario: View a vtt session
    Given I am logged in as a user
    And a vtt session exists
    When I visit the vtt session page
    Then I should see the vtt session details
