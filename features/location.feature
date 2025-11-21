Feature: Location Management
  As a user
  I want to manage locations
  So that I can track my game data

  Scenario: Create a new location
    Given I am logged in as a user
    When I visit the new location page
    And I fill in the location form
    And I submit the form
    Then I should see the location was created

  Scenario: View a location
    Given I am logged in as a user
    And a location exists
    When I visit the location page
    Then I should see the location details
