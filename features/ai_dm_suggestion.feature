Feature: Ai dm suggestion Management
  As a user
  I want to manage ai dm suggestions
  So that I can track my game data

  Scenario: Create a new ai dm suggestion
    Given I am logged in as a user
    When I visit the new ai dm suggestion page
    And I fill in the ai dm suggestion form
    And I submit the form
    Then I should see the ai dm suggestion was created

  Scenario: View a ai dm suggestion
    Given I am logged in as a user
    And a ai dm suggestion exists
    When I visit the ai dm suggestion page
    Then I should see the ai dm suggestion details
