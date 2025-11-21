Feature: User theme preference Management
  As a user
  I want to manage user theme preferences
  So that I can track my game data

  Scenario: Create a new user theme preference
    Given I am logged in as a user
    When I visit the new user theme preference page
    And I fill in the user theme preference form
    And I submit the form
    Then I should see the user theme preference was created

  Scenario: View a user theme preference
    Given I am logged in as a user
    And a user theme preference exists
    When I visit the user theme preference page
    Then I should see the user theme preference details
