Feature: Vtt token Management
  As a user
  I want to manage vtt tokens
  So that I can track my game data

  Scenario: Create a new vtt token
    Given I am logged in as a user
    When I visit the new vtt token page
    And I fill in the vtt token form
    And I submit the form
    Then I should see the vtt token was created

  Scenario: View a vtt token
    Given I am logged in as a user
    And a vtt token exists
    When I visit the vtt token page
    Then I should see the vtt token details
