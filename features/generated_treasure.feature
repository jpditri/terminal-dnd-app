Feature: Generated treasure Management
  As a user
  I want to manage generated treasures
  So that I can track my game data

  Scenario: Create a new generated treasure
    Given I am logged in as a user
    When I visit the new generated treasure page
    And I fill in the generated treasure form
    And I submit the form
    Then I should see the generated treasure was created

  Scenario: View a generated treasure
    Given I am logged in as a user
    And a generated treasure exists
    When I visit the generated treasure page
    Then I should see the generated treasure details
