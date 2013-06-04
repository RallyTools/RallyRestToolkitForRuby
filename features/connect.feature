

Feature: example 01

  In order test the examples scripts
  As a developer using the rally api gem
  I want the 01-connect-to-rally.rb script to run.

  Scenario: Create a rally connection
    Given a config file "00-config.rb"
    When I create RallyRestJson
    Then I should see the Rally API version number of "0.9.14"

  Scenario: Run the 01-connect-to-rally.rb
    Given that "00-config.rb" exists in the examples directory
    When I run `01-connect-to-rally.rb`
    Then the exit status should be 0

  Scenario: Check the output of 01-connect-to-rally.rb
    Given that "00-config.rb" exists in the examples directory
    When I run `01-connect-to-rally.rb`
    Then the output should contain "0.9.14"