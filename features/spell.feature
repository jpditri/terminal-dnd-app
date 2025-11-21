Feature: Spell Management
  As a user
  I want to manage spells
  So that I can track my game data

  Scenario: Create a new spell
    Given I am logged in as a user
    When I visit the new spell page
    And I fill in the spell form
    And I submit the form
    Then I should see the spell was created

  Scenario: View a spell
    Given I am logged in as a user
    And a spell exists
    When I visit the spell page
    Then I should see the spell details
