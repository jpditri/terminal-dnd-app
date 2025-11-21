Feature: Character template Management
  As a user
  I want to manage character templates
  So that I can track my game data

  Scenario: Create a new character template
    Given I am logged in as a user
    When I visit the new character template page
    And I fill in the character template form
    And I submit the form
    Then I should see the character template was created

  Scenario: View a character template
    Given I am logged in as a user
    And a character template exists
    When I visit the character template page
    Then I should see the character template details
