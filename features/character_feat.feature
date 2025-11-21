Feature: Character feat Management
  As a user
  I want to manage character feats
  So that I can track my game data

  Scenario: Create a new character feat
    Given I am logged in as a user
    When I visit the new character feat page
    And I fill in the character feat form
    And I submit the form
    Then I should see the character feat was created

  Scenario: View a character feat
    Given I am logged in as a user
    And a character feat exists
    When I visit the character feat page
    Then I should see the character feat details
