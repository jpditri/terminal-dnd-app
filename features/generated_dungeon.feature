Feature: Generated dungeon Management
  As a user
  I want to manage generated dungeons
  So that I can track my game data

  Scenario: Create a new generated dungeon
    Given I am logged in as a user
    When I visit the new generated dungeon page
    And I fill in the generated dungeon form
    And I submit the form
    Then I should see the generated dungeon was created

  Scenario: View a generated dungeon
    Given I am logged in as a user
    And a generated dungeon exists
    When I visit the generated dungeon page
    Then I should see the generated dungeon details
