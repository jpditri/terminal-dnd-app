Feature: User block Management
  As a user
  I want to manage user blocks
  So that I can track my game data

  Scenario: Create a new user block
    Given I am logged in as a user
    When I visit the new user block page
    And I fill in the user block form
    And I submit the form
    Then I should see the user block was created

  Scenario: View a user block
    Given I am logged in as a user
    And a user block exists
    When I visit the user block page
    Then I should see the user block details
