Feature: Friend request Management
  As a user
  I want to manage friend requests
  So that I can track my game data

  Scenario: Create a new friend request
    Given I am logged in as a user
    When I visit the new friend request page
    And I fill in the friend request form
    And I submit the form
    Then I should see the friend request was created

  Scenario: View a friend request
    Given I am logged in as a user
    And a friend request exists
    When I visit the friend request page
    Then I should see the friend request details
