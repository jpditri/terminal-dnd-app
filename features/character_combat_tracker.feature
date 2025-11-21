Feature: Character combat tracker Management
  As a user
  I want to manage character combat trackers
  So that I can track my game data

  Scenario: Create a new character combat tracker
    Given I am logged in as a user
    When I visit the new character combat tracker page
    And I fill in the character combat tracker form
    And I submit the form
    Then I should see the character combat tracker was created

  Scenario: View a character combat tracker
    Given I am logged in as a user
    And a character combat tracker exists
    When I visit the character combat tracker page
    Then I should see the character combat tracker details
