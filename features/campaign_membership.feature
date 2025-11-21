Feature: Campaign membership Management
  As a user
  I want to manage campaign memberships
  So that I can track my game data

  Scenario: Create a new campaign membership
    Given I am logged in as a user
    When I visit the new campaign membership page
    And I fill in the campaign membership form
    And I submit the form
    Then I should see the campaign membership was created

  Scenario: View a campaign membership
    Given I am logged in as a user
    And a campaign membership exists
    When I visit the campaign membership page
    Then I should see the campaign membership details
