Feature: Ai dm assistant Management
  As a user
  I want to manage ai dm assistants
  So that I can track my game data

  Scenario: Create a new ai dm assistant
    Given I am logged in as a user
    When I visit the new ai dm assistant page
    And I fill in the ai dm assistant form
    And I submit the form
    Then I should see the ai dm assistant was created

  Scenario: View a ai dm assistant
    Given I am logged in as a user
    And a ai dm assistant exists
    When I visit the ai dm assistant page
    Then I should see the ai dm assistant details
