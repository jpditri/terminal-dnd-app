Feature: User Management
  As a user
  I want to manage users
  So that I can track my game data

  Scenario: Create a new user
    Given I am logged in as a user
    When I visit the new user page
    And I fill in the user form
    And I submit the form
    Then I should see the user was created

  Scenario: View a user
    Given I am logged in as a user
    And a user exists
    When I visit the user page
    Then I should see the user details
