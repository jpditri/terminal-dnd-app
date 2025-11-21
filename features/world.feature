Feature: World Management
  As a user
  I want to manage worlds
  So that I can track my game data

  Scenario: Create a new world
    Given I am logged in as a user
    When I visit the new world page
    And I fill in the world form
    And I submit the form
    Then I should see the world was created

  Scenario: View a world
    Given I am logged in as a user
    And a world exists
    When I visit the world page
    Then I should see the world details
