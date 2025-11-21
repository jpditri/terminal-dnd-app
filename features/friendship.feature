Feature: Friendship Management
  As a user
  I want to manage friendships
  So that I can track my game data

  Scenario: Create a new friendship
    Given I am logged in as a user
    When I visit the new friendship page
    And I fill in the friendship form
    And I submit the form
    Then I should see the friendship was created

  Scenario: View a friendship
    Given I am logged in as a user
    And a friendship exists
    When I visit the friendship page
    Then I should see the friendship details
