*** Settings ***
Documentation     Common keywords for Grid pages
Resource          ../Common/Common.robot

*** Keywords ***
Search icon is shown in grid navigation
    [Documentation]    This keyword verifies that the Search icon is Shown in the grid navigation component.
    I expect page element 'id:gridNavigation_searchIcon' contains 'iconKeys:SEARCH'

Counter is shown in small header
	[Documentation]    Checks if a small header counter is shown on the page
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadSecondaryTitle' contains 'textValue:.*\\\\d+ \\\\/ \\\\d+$' using regular expressions

Small header is shown
    [Documentation]    Checks if a small header is shown on the page
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadBackgroundScrolled' contains 'opacity:255'
