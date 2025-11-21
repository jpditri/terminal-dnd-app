Feature: Session recap Management
  As a user
  I want to manage session recaps
  So that I can track my game data

  Scenario: Create a new session recap
    Given I am logged in as a user
    When I visit the new session recap page
    And I fill in the session recap form
    And I submit the form
    Then I should see the session recap was created

  Scenario: View a session recap
    Given I am logged in as a user
    And a session recap exists
    When I visit the session recap page
    Then I should see the session recap details
