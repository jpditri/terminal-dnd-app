Feature: Export archive Management
  As a user
  I want to manage export archives
  So that I can track my game data

  Scenario: Create a new export archive
    Given I am logged in as a user
    When I visit the new export archive page
    And I fill in the export archive form
    And I submit the form
    Then I should see the export archive was created

  Scenario: View a export archive
    Given I am logged in as a user
    And a export archive exists
    When I visit the export archive page
    Then I should see the export archive details
