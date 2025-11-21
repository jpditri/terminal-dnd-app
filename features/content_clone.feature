Feature: Content clone Management
  As a user
  I want to manage content clones
  So that I can track my game data

  Scenario: Create a new content clone
    Given I am logged in as a user
    When I visit the new content clone page
    And I fill in the content clone form
    And I submit the form
    Then I should see the content clone was created

  Scenario: View a content clone
    Given I am logged in as a user
    And a content clone exists
    When I visit the content clone page
    Then I should see the content clone details
