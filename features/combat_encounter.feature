Feature: Combat encounter Management
  As a user
  I want to manage combat encounters
  So that I can track my game data

  Scenario: Create a new combat encounter
    Given I am logged in as a user
    When I visit the new combat encounter page
    And I fill in the combat encounter form
    And I submit the form
    Then I should see the combat encounter was created

  Scenario: View a combat encounter
    Given I am logged in as a user
    And a combat encounter exists
    When I visit the combat encounter page
    Then I should see the combat encounter details
