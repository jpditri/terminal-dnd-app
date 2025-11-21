Feature: Character Management
  As a user
  I want to manage characters
  So that I can track my game data

  Scenario: Create a new character
    Given I am logged in as a user
    When I visit the new character page
    And I fill in the character form
    And I submit the form
    Then I should see the character was created

  Scenario: View a character
    Given I am logged in as a user
    And a character exists
    When I visit the character page
    Then I should see the character details
