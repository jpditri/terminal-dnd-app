Feature: Character inventory Management
  As a user
  I want to manage character inventories
  So that I can track my game data

  Scenario: Create a new character inventory
    Given I am logged in as a user
    When I visit the new character inventory page
    And I fill in the character inventory form
    And I submit the form
    Then I should see the character inventory was created

  Scenario: View a character inventory
    Given I am logged in as a user
    And a character inventory exists
    When I visit the character inventory page
    Then I should see the character inventory details
