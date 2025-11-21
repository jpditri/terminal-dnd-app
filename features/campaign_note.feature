Feature: Campaign note Management
  As a user
  I want to manage campaign notes
  So that I can track my game data

  Scenario: Create a new campaign note
    Given I am logged in as a user
    When I visit the new campaign note page
    And I fill in the campaign note form
    And I submit the form
    Then I should see the campaign note was created

  Scenario: View a campaign note
    Given I am logged in as a user
    And a campaign note exists
    When I visit the campaign note page
    Then I should see the campaign note details
