Feature: Feat Management
  As a user
  I want to manage feats
  So that I can track my game data

  Scenario: Create a new feat
    Given I am logged in as a user
    When I visit the new feat page
    And I fill in the feat form
    And I submit the form
    Then I should see the feat was created

  Scenario: View a feat
    Given I am logged in as a user
    And a feat exists
    When I visit the feat page
    Then I should see the feat details
