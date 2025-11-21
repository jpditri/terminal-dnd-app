Feature: Character note Management
  As a user
  I want to manage character notes
  So that I can track my game data

  Scenario: Create a new character note
    Given I am logged in as a user
    When I visit the new character note page
    And I fill in the character note form
    And I submit the form
    Then I should see the character note was created

  Scenario: View a character note
    Given I am logged in as a user
    And a character note exists
    When I visit the character note page
    Then I should see the character note details
