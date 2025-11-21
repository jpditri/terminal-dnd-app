Feature: Spell filter preset Management
  As a user
  I want to manage spell filter presets
  So that I can track my game data

  Scenario: Create a new spell filter preset
    Given I am logged in as a user
    When I visit the new spell filter preset page
    And I fill in the spell filter preset form
    And I submit the form
    Then I should see the spell filter preset was created

  Scenario: View a spell filter preset
    Given I am logged in as a user
    And a spell filter preset exists
    When I visit the spell filter preset page
    Then I should see the spell filter preset details
