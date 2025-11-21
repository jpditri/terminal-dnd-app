Feature: Template rating Management
  As a user
  I want to manage template ratings
  So that I can track my game data

  Scenario: Create a new template rating
    Given I am logged in as a user
    When I visit the new template rating page
    And I fill in the template rating form
    And I submit the form
    Then I should see the template rating was created

  Scenario: View a template rating
    Given I am logged in as a user
    And a template rating exists
    When I visit the template rating page
    Then I should see the template rating details
