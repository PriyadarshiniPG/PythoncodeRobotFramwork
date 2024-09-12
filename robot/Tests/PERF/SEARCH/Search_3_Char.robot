*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CCN-Search_3   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    RERUN-PROD-UK    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           ShanmugaPriyan Mohan
#Modified         Khushal M Jain

*** Test Cases ***
Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    Run Keyword And Assert Failed Reason     I open Main Menu    'Unable to Open Main Menu'

Validate whether Main Menu is Displayed
    [Documentation]    Validates Main Menu is Displayed.
    [Setup]    Skip If Last Fail
    wait until keyword succeeds    20 times    0    Main Menu is shown

Navigate to Search
   [Documentation]    Validates to Search in CMM.
   [Setup]    Skip If Last Fail
   set context  Search_Char_3
   Run Keyword And Assert Failed Reason     I focus Search    'Navigate to Search is Failed.'
   #Run Keyword And Assert Failed Reason     Search is focused    'Search in CMM is not Focused.'

Open Search thorugh CMM
   [Documentation]    Opens Search through CMM.
   [Setup]    Skip If Last Fail
   Run Keyword And Assert Failed Reason     I open Search    'Search Opening is Failed.'
   Run Keyword And Assert Failed Reason     Search screen is shown    'Screen Search in not shown.'
   Run Keyword And Assert Failed Reason     I have searched for '${SEARCH_CHAR_3}'     'Failed to Search for content.'
   log action  SearchResultsDisplayed
   wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Search results are shown for '${SEARCH_CHAR_3}'
   log action  SearchResultsDisplayed_Done