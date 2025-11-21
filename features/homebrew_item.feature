Feature: Homebrew item Management
  As a user
  I want to manage homebrew items
  So that I can track my game data

  Scenario: Create a new homebrew item
    Given I am logged in as a user
    When I visit the new homebrew item page
    And I fill in the homebrew item form
    And I submit the form
    Then I should see the homebrew item was created

  Scenario: View a homebrew item
    Given I am logged in as a user
    And a homebrew item exists
    When I visit the homebrew item page
    Then I should see the homebrew item details
