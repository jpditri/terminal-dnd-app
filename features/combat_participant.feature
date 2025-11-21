Feature: Combat participant Management
  As a user
  I want to manage combat participants
  So that I can track my game data

  Scenario: Create a new combat participant
    Given I am logged in as a user
    When I visit the new combat participant page
    And I fill in the combat participant form
    And I submit the form
    Then I should see the combat participant was created

  Scenario: View a combat participant
    Given I am logged in as a user
    And a combat participant exists
    When I visit the combat participant page
    Then I should see the combat participant details
