Feature: Campaign join request Management
  As a user
  I want to manage campaign join requests
  So that I can track my game data

  Scenario: Create a new campaign join request
    Given I am logged in as a user
    When I visit the new campaign join request page
    And I fill in the campaign join request form
    And I submit the form
    Then I should see the campaign join request was created

  Scenario: View a campaign join request
    Given I am logged in as a user
    And a campaign join request exists
    When I visit the campaign join request page
    Then I should see the campaign join request details
