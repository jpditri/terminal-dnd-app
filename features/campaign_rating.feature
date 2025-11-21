Feature: Campaign rating Management
  As a user
  I want to manage campaign ratings
  So that I can track my game data

  Scenario: Create a new campaign rating
    Given I am logged in as a user
    When I visit the new campaign rating page
    And I fill in the campaign rating form
    And I submit the form
    Then I should see the campaign rating was created

  Scenario: View a campaign rating
    Given I am logged in as a user
    And a campaign rating exists
    When I visit the campaign rating page
    Then I should see the campaign rating details
