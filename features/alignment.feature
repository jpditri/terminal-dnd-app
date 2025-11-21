Feature: Alignment Management
  As a user
  I want to manage alignments
  So that I can track my game data

  Scenario: Create a new alignment
    Given I am logged in as a user
    When I visit the new alignment page
    And I fill in the alignment form
    And I submit the form
    Then I should see the alignment was created

  Scenario: View a alignment
    Given I am logged in as a user
    And a alignment exists
    When I visit the alignment page
    Then I should see the alignment details
