Feature: Ai dm override Management
  As a user
  I want to manage ai dm overrides
  So that I can track my game data

  Scenario: Create a new ai dm override
    Given I am logged in as a user
    When I visit the new ai dm override page
    And I fill in the ai dm override form
    And I submit the form
    Then I should see the ai dm override was created

  Scenario: View a ai dm override
    Given I am logged in as a user
    And a ai dm override exists
    When I visit the ai dm override page
    Then I should see the ai dm override details
