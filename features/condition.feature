Feature: Condition Management
  As a user
  I want to manage conditions
  So that I can track my game data

  Scenario: Create a new condition
    Given I am logged in as a user
    When I visit the new condition page
    And I fill in the condition form
    And I submit the form
    Then I should see the condition was created

  Scenario: View a condition
    Given I am logged in as a user
    And a condition exists
    When I visit the condition page
    Then I should see the condition details
