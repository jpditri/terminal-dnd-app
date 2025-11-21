Feature: Character item Management
  As a user
  I want to manage character items
  So that I can track my game data

  Scenario: Create a new character item
    Given I am logged in as a user
    When I visit the new character item page
    And I fill in the character item form
    And I submit the form
    Then I should see the character item was created

  Scenario: View a character item
    Given I am logged in as a user
    And a character item exists
    When I visit the character item page
    Then I should see the character item details
