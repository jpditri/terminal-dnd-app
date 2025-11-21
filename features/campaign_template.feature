Feature: Campaign template Management
  As a user
  I want to manage campaign templates
  So that I can track my game data

  Scenario: Create a new campaign template
    Given I am logged in as a user
    When I visit the new campaign template page
    And I fill in the campaign template form
    And I submit the form
    Then I should see the campaign template was created

  Scenario: View a campaign template
    Given I am logged in as a user
    And a campaign template exists
    When I visit the campaign template page
    Then I should see the campaign template details
