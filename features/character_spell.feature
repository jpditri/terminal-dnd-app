Feature: Character spell Management
  As a user
  I want to manage character spells
  So that I can track my game data

  Scenario: Create a new character spell
    Given I am logged in as a user
    When I visit the new character spell page
    And I fill in the character spell form
    And I submit the form
    Then I should see the character spell was created

  Scenario: View a character spell
    Given I am logged in as a user
    And a character spell exists
    When I visit the character spell page
    Then I should see the character spell details
