Feature: Combat action Management
  As a user
  I want to manage combat actions
  So that I can track my game data

  Scenario: Create a new combat action
    Given I am logged in as a user
    When I visit the new combat action page
    And I fill in the combat action form
    And I submit the form
    Then I should see the combat action was created

  Scenario: View a combat action
    Given I am logged in as a user
    And a combat action exists
    When I visit the combat action page
    Then I should see the combat action details
