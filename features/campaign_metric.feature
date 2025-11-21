Feature: Campaign metric Management
  As a user
  I want to manage campaign metrics
  So that I can track my game data

  Scenario: Create a new campaign metric
    Given I am logged in as a user
    When I visit the new campaign metric page
    And I fill in the campaign metric form
    And I submit the form
    Then I should see the campaign metric was created

  Scenario: View a campaign metric
    Given I am logged in as a user
    And a campaign metric exists
    When I visit the campaign metric page
    Then I should see the campaign metric details
