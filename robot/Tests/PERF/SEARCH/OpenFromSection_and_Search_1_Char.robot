*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        OpenFromSection_Search_1   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PROD-PL-APOLLO    PROD-IE-EOS    RERUN-PROD-UK    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies sections
#    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu'
#    Run Keyword And Assert Failed Reason    I open Apps through Main Menu    'Unable to tv apps from main menu'
    Run Keyword And Assert Failed Reason    I open Saved through Main Menu    'Unable to open recording page from main menu.'

Navigate to Search
   [Documentation]    Validates to Search in Section.
   [Setup]    Skip If Last Fail
   set context  OpenFromSection_Search_Char_1
   Run Keyword And Assert Failed Reason     I focus Search Saved    'Search Opening is Failed.'
   I Press    OK

Open Search thorugh sections
   [Documentation]    Opens Search through sections.
   [Setup]    Skip If Last Fail
   log action  SearchScreenShown
   Run Keyword And Assert Failed Reason     Search screen is shown    'Screen Search in not shown.'
   log action  SearchScreenShown_Done
   Run Keyword And Assert Failed Reason     I have searched for '${SEARCH_CHAR_1}'     'Failed to Search for content.'
   log action  SearchResultsDisplayed
   wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Search results are shown for '${SEARCH_CHAR_1}'
   log action  SearchResultsDisplayed_Done