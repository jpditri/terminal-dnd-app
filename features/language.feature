Feature: Language Management
  As a user
  I want to manage languages
  So that I can track my game data

  Scenario: Create a new language
    Given I am logged in as a user
    When I visit the new language page
    And I fill in the language form
    And I submit the form
    Then I should see the language was created

  Scenario: View a language
    Given I am logged in as a user
    And a language exists
    When I visit the language page
    Then I should see the language details
