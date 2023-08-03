@something
Feature: Something
    As an API consumer
    I want something
    So that I do something else

    @something
    Scenario: GET /foo request not found
        Given I do something
        Given I set X-APIKey header to `clientId`
        When I GET /foo
        Then response code should be 404
 