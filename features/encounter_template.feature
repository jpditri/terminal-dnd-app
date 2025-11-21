Feature: Encounter template Management
  As a user
  I want to manage encounter templates
  So that I can track my game data

  Scenario: Create a new encounter template
    Given I am logged in as a user
    When I visit the new encounter template page
    And I fill in the encounter template form
    And I submit the form
    Then I should see the encounter template was created

  Scenario: View a encounter template
    Given I am logged in as a user
    And a encounter template exists
    When I visit the encounter template page
    Then I should see the encounter template details
