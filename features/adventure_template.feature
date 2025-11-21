Feature: Adventure template Management
  As a user
  I want to manage adventure templates
  So that I can track my game data

  Scenario: Create a new adventure template
    Given I am logged in as a user
    When I visit the new adventure template page
    And I fill in the adventure template form
    And I submit the form
    Then I should see the adventure template was created

  Scenario: View a adventure template
    Given I am logged in as a user
    And a adventure template exists
    When I visit the adventure template page
    Then I should see the adventure template details
