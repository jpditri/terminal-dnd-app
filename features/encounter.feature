Feature: Encounter Management
  As a user
  I want to manage encounters
  So that I can track my game data

  Scenario: Create a new encounter
    Given I am logged in as a user
    When I visit the new encounter page
    And I fill in the encounter form
    And I submit the form
    Then I should see the encounter was created

  Scenario: View a encounter
    Given I am logged in as a user
    And a encounter exists
    When I visit the encounter page
    Then I should see the encounter details
