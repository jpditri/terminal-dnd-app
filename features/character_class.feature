Feature: Character class Management
  As a user
  I want to manage character classes
  So that I can track my game data

  Scenario: Create a new character class
    Given I am logged in as a user
    When I visit the new character class page
    And I fill in the character class form
    And I submit the form
    Then I should see the character class was created

  Scenario: View a character class
    Given I am logged in as a user
    And a character class exists
    When I visit the character class page
    Then I should see the character class details
