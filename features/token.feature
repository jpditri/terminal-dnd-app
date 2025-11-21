Feature: Token Management
  As a user
  I want to manage tokens
  So that I can track my game data

  Scenario: Create a new token
    Given I am logged in as a user
    When I visit the new token page
    And I fill in the token form
    And I submit the form
    Then I should see the token was created

  Scenario: View a token
    Given I am logged in as a user
    And a token exists
    When I visit the token page
    Then I should see the token details
