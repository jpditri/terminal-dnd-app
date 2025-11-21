Feature: Background Management
  As a user
  I want to manage backgrounds
  So that I can track my game data

  Scenario: Create a new background
    Given I am logged in as a user
    When I visit the new background page
    And I fill in the background form
    And I submit the form
    Then I should see the background was created

  Scenario: View a background
    Given I am logged in as a user
    And a background exists
    When I visit the background page
    Then I should see the background details
