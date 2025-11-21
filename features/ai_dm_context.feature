Feature: Ai dm context Management
  As a user
  I want to manage ai dm contexts
  So that I can track my game data

  Scenario: Create a new ai dm context
    Given I am logged in as a user
    When I visit the new ai dm context page
    And I fill in the ai dm context form
    And I submit the form
    Then I should see the ai dm context was created

  Scenario: View a ai dm context
    Given I am logged in as a user
    And a ai dm context exists
    When I visit the ai dm context page
    Then I should see the ai dm context details
