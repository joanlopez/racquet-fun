Feature: user onboarding
  In order to be happy
  As a racquet player
  I need to be able to be onboarded

  Scenario: Standard onboard
    Given a new user is signed up
    When the user waits for the welcome email
    And activates its recently created account
    Then the user should be able to sign in
    And should be able to fetch its profile
