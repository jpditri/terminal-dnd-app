Feature: Vtt map Management
  As a user
  I want to manage vtt maps
  So that I can track my game data

  Scenario: Create a new vtt map
    Given I am logged in as a user
    When I visit the new vtt map page
    And I fill in the vtt map form
    And I submit the form
    Then I should see the vtt map was created

  Scenario: View a vtt map
    Given I am logged in as a user
    And a vtt map exists
    When I visit the vtt map page
    Then I should see the vtt map details
