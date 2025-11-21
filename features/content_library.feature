Feature: Content library Management
  As a user
  I want to manage content libraries
  So that I can track my game data

  Scenario: Create a new content library
    Given I am logged in as a user
    When I visit the new content library page
    And I fill in the content library form
    And I submit the form
    Then I should see the content library was created

  Scenario: View a content library
    Given I am logged in as a user
    And a content library exists
    When I visit the content library page
    Then I should see the content library details
