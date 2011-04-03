Feature: change the head for git code browser

  As an authorized user
  I want to change the head
  So that I am not limited to one head, only

  Scenario: display multiple heads
    Given a git repository "git_test.git"
    When I list the heads
    Then the list of heads should contain 2 entries

  Scenario: change head
    Given a git repository "git_test.git"
    When the current head is "master"
    And "/" contains the entries
    | Blob | .gitmodules   |
    | Tree | retro-copied  |
    | Tree | retrospectiva |
    And I switch to "experimental"
    Then "/" contains the entries
    | Tree | retrospectiva |
    And "retrospectiva" contains the entries
    | Tree | config |
    | Tree | public |
