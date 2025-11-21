Feature: Generated encounter Management
  As a user
  I want to manage generated encounters
  So that I can track my game data

  Scenario: Create a new generated encounter
    Given I am logged in as a user
    When I visit the new generated encounter page
    And I fill in the generated encounter form
    And I submit the form
    Then I should see the generated encounter was created

  Scenario: View a generated encounter
    Given I am logged in as a user
    And a generated encounter exists
    When I visit the generated encounter page
    Then I should see the generated encounter details
