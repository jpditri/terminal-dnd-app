Feature: Map Management
  As a user
  I want to manage maps
  So that I can track my game data

  Scenario: Create a new map
    Given I am logged in as a user
    When I visit the new map page
    And I fill in the map form
    And I submit the form
    Then I should see the map was created

  Scenario: View a map
    Given I am logged in as a user
    And a map exists
    When I visit the map page
    Then I should see the map details
