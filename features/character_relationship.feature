Feature: Character relationship Management
  As a user
  I want to manage character relationships
  So that I can track my game data

  Scenario: Create a new character relationship
    Given I am logged in as a user
    When I visit the new character relationship page
    And I fill in the character relationship form
    And I submit the form
    Then I should see the character relationship was created

  Scenario: View a character relationship
    Given I am logged in as a user
    And a character relationship exists
    When I visit the character relationship page
    Then I should see the character relationship details
