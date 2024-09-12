*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_PHS_ProfileSwitch   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-APOLLO    PROD-CH-EOSV2    PROD-CH-EOS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Variables ***
${number_of_profiles}    2
${number_of_char}        4

*** Test Cases ***
Create A New Profile
     [Documentation]    Creates a new profile.
     @{customer_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
     ${number_of_profiles_exist}    Get length    ${customer_profile}
     ${status}    set variable if  ${number_of_profiles_exist} == 1    ${True}    ${False}
     Run Keyword If   ${status}    I Create '${number_of_profiles}' Of Custom Profiles With '${number_of_char}' In Name From BO
     Run Keyword And Assert Failed Reason    switch to 'Shared' profile    Failed to switch to shared profile

Validate PHS is displayed properly after profile switch
     [Documentation]    Validate PHS is displayed properly after profile switch
     [Tags]    CCH-3407
     [Setup]    Skip If Last Fail
     I open Main Menu
     I press    PROFILE
     I wait for 2 second
     I press    RIGHT
     I press    OK
     set context    SwitchProfile
     log action    PHSDisplayed
     wait until keyword succeeds    50 s    0 s    Validate Profile switch from PHS
     log action  PHSDisplayed_Done
     Run Keyword And Assert Failed Reason    switch to 'Shared' profile    Failed to switch to shared profile




#Delete Inactive Profile And Validate
#   [Documentation]    This test deletes the inactive custom profile
#   [Tags]     CCH-3407
#   Run Keyword And Assert Failed Reason    I Delete LZQD And Validate   'Deletion Not Successfull'
#   Run Keyword And Assert Failed Reason    I Delete LaWJ And Validate   'Deletion Not Successfull'
#   Run Keyword And Assert Failed Reason    I Delete csmQ And Validate   'Deletion Not Successfull'
#   Run Keyword And Assert Failed Reason    I Delete JQnP And Validate   'Deletion Not Successfull'
#   Run Keyword And Assert Failed Reason    I Delete TzPY And Validate   'Deletion Not Successfull'
#   Run Keyword And Assert Failed Reason    I Delete cFKB And Validate   'Deletion Not Successfull'