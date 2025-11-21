Feature: Active effect Management
  As a user
  I want to manage active effects
  So that I can track my game data

  Scenario: Create a new active effect
    Given I am logged in as a user
    When I visit the new active effect page
    And I fill in the active effect form
    And I submit the form
    Then I should see the active effect was created

  Scenario: View a active effect
    Given I am logged in as a user
    And a active effect exists
    When I visit the active effect page
    Then I should see the active effect details
