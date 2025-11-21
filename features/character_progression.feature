Feature: Character progression Management
  As a user
  I want to manage character progressions
  So that I can track my game data

  Scenario: Create a new character progression
    Given I am logged in as a user
    When I visit the new character progression page
    And I fill in the character progression form
    And I submit the form
    Then I should see the character progression was created

  Scenario: View a character progression
    Given I am logged in as a user
    And a character progression exists
    When I visit the character progression page
    Then I should see the character progression details
