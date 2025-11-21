Feature: Content rating Management
  As a user
  I want to manage content ratings
  So that I can track my game data

  Scenario: Create a new content rating
    Given I am logged in as a user
    When I visit the new content rating page
    And I fill in the content rating form
    And I submit the form
    Then I should see the content rating was created

  Scenario: View a content rating
    Given I am logged in as a user
    And a content rating exists
    When I visit the content rating page
    Then I should see the content rating details
