Feature: Campaign Management
  As a user
  I want to manage campaigns
  So that I can track my game data

  Scenario: Create a new campaign
    Given I am logged in as a user
    When I visit the new campaign page
    And I fill in the campaign form
    And I submit the form
    Then I should see the campaign was created

  Scenario: View a campaign
    Given I am logged in as a user
    And a campaign exists
    When I visit the campaign page
    Then I should see the campaign details
