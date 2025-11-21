Feature: Character ai assistant Management
  As a user
  I want to manage character ai assistants
  So that I can track my game data

  Scenario: Create a new character ai assistant
    Given I am logged in as a user
    When I visit the new character ai assistant page
    And I fill in the character ai assistant form
    And I submit the form
    Then I should see the character ai assistant was created

  Scenario: View a character ai assistant
    Given I am logged in as a user
    And a character ai assistant exists
    When I visit the character ai assistant page
    Then I should see the character ai assistant details
