Feature: Solo session Management
  As a user
  I want to manage solo sessions
  So that I can track my game data

  Scenario: Create a new solo session
    Given I am logged in as a user
    When I visit the new solo session page
    And I fill in the solo session form
    And I submit the form
    Then I should see the solo session was created

  Scenario: View a solo session
    Given I am logged in as a user
    And a solo session exists
    When I visit the solo session page
    Then I should see the solo session details
