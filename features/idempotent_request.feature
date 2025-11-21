Feature: Idempotent request Management
  As a user
  I want to manage idempotent requests
  So that I can track my game data

  Scenario: Create a new idempotent request
    Given I am logged in as a user
    When I visit the new idempotent request page
    And I fill in the idempotent request form
    And I submit the form
    Then I should see the idempotent request was created

  Scenario: View a idempotent request
    Given I am logged in as a user
    And a idempotent request exists
    When I visit the idempotent request page
    Then I should see the idempotent request details
