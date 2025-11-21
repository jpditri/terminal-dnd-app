Feature: Message reaction Management
  As a user
  I want to manage message reactions
  So that I can track my game data

  Scenario: Create a new message reaction
    Given I am logged in as a user
    When I visit the new message reaction page
    And I fill in the message reaction form
    And I submit the form
    Then I should see the message reaction was created

  Scenario: View a message reaction
    Given I am logged in as a user
    And a message reaction exists
    When I visit the message reaction page
    Then I should see the message reaction details
