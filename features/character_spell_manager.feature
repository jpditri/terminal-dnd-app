Feature: Character spell manager Management
  As a user
  I want to manage character spell managers
  So that I can track my game data

  Scenario: Create a new character spell manager
    Given I am logged in as a user
    When I visit the new character spell manager page
    And I fill in the character spell manager form
    And I submit the form
    Then I should see the character spell manager was created

  Scenario: View a character spell manager
    Given I am logged in as a user
    And a character spell manager exists
    When I visit the character spell manager page
    Then I should see the character spell manager details
