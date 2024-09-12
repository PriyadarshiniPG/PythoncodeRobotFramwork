*** Settings ***
Documentation     Keywords for PersonalizationService
Resource          ./PersonalizationService_Implementation.robot

*** Keywords ***
Get cityID via personalization service if it is default    #USED
    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${CUSTOMER_ID}   ${city_id}=${CITY_ID}
    [Documentation]    This keyword try to retrieve the City_ID from the personalization service
    ...    only if CITY_ID is not define on rack_details - CITY_ID = default
    Run Keyword If    '${city_id}' == 'default'    log to console    \nTrying to get CITY_ID from the personalization services
    ${city_id_ps}    Run Keyword If    '${city_id}' == 'default'    get cityid via personalization service    ${lab_conf}    ${customer_id}    ELSE    Set variable    ${CITY_ID}
    ${city_id}    convert to string    ${city_id_ps}
    set suite variable  ${CITY_ID}    ${city_id}
    log to console    CITY_ID: ${CITY_ID}
    should not be empty    ${CITY_ID}    Error: The city ID is empty
    [Return]    ${CITY_ID}

I Get The Active Profile Color    #USED
    [Documentation]  The keyword gets the profile color for active profile from BO
    ${current_profile}    I Get The Active Profile Name
    ${profile_details}    I Get The Profile Details From BO
    ${profiles}   Extract Value For Key    ${profile_details}    ${EMPTY}   profiles
    ${profile_color}   Extract Value For Key    ${profiles}    name:${current_profile}     colour
    [Return]   ${profile_color}

I Get Customer Id From Personalization Service    #USED
    [Documentation]    This keyword returns the Customer Id for a device Id provided.
    ${customer_id}    Get Customer Id From Personalization Service
    Set Suite Variable    ${CUSTOMER_ID}    ${customer_id}
    [Return]    ${CUSTOMER_ID}

I Get The Number Of Custom Profiles     #USED
    [Documentation]   This keyword returns the number of custom profiles craeted
    @{profile_list}   I Get The Profile Names From BO
    ${number_of_profiles}    Get Length    ${profile_list}
    [Return]  ${number_of_profiles} - 1

Create A Profile Via Personalization Service     #USED
    [Documentation]  This keyword creates a custom profile
    [Arguments]      ${profile_name}    ${profile_color}
    ${profile_id}    I Create A New Profile Via Personalization Service    ${profile_name}    ${profile_color}
    [Return]    ${profile_id}

