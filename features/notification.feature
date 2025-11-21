Feature: Notification Management
  As a user
  I want to manage notifications
  So that I can track my game data

  Scenario: Create a new notification
    Given I am logged in as a user
    When I visit the new notification page
    And I fill in the notification form
    And I submit the form
    Then I should see the notification was created

  Scenario: View a notification
    Given I am logged in as a user
    And a notification exists
    When I visit the notification page
    Then I should see the notification details
