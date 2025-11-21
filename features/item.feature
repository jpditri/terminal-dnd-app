Feature: Item Management
  As a user
  I want to manage items
  So that I can track my game data

  Scenario: Create a new item
    Given I am logged in as a user
    When I visit the new item page
    And I fill in the item form
    And I submit the form
    Then I should see the item was created

  Scenario: View a item
    Given I am logged in as a user
    And a item exists
    When I visit the item page
    Then I should see the item details
