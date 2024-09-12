*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        OpenFromTvGuide_Search_1   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PROD-PL-APOLLO    PROD-IE-EOS    RERUN-PROD-UK    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Validates Whether TVGuide is Opened Successfully
    [Documentation]    Validates Whether TVGuide is Opened Successfully.
    I open Guide through Main Menu
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded

Navigate to Search
   [Documentation]    Validates to Search in Tv Guide.
   [Setup]    Skip If Last Fail
   set context  OpenFromTvGuide_Search_Char_1
   I Press    MENU
   Run Keyword And Assert Failed Reason     I focus Search    'Navigate to Search is Failed.'
   I press    OK

Open Search thorugh TvGuide
   [Documentation]    Opens Search through TvGuide.
   [Setup]    Skip If Last Fail
   log action  SearchScreenShown
   Run Keyword And Assert Failed Reason     Search screen is shown    'Screen Search in not shown.'
   log action  SearchScreenShown_Done
   Run Keyword And Assert Failed Reason     I have searched for '${SEARCH_CHAR_1}'     'Failed to Search for content.'
   log action  SearchResultsDisplayed
   wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Search results are shown for '${SEARCH_CHAR_1}'
   log action  SearchResultsDisplayed_Done