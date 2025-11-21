Feature: Shared content Management
  As a user
  I want to manage shared contents
  So that I can track my game data

  Scenario: Create a new shared content
    Given I am logged in as a user
    When I visit the new shared content page
    And I fill in the shared content form
    And I submit the form
    Then I should see the shared content was created

  Scenario: View a shared content
    Given I am logged in as a user
    And a shared content exists
    When I visit the shared content page
    Then I should see the shared content details
