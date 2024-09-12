*** Settings ***
Documentation     Implementation Keywords for PersonalizationService
Library           Libraries.MicroServices.PersonalizationService

*** Keywords ***
I Get The Profile Names From BO  #USED
    [Documentation]  The keyword gets the profile names from backedn and returns the custom profile list.
    @{customer_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
    [RETURN]  ${customer_profile}

I Get The Active Profile Name   #USED
    [Documentation]   The active profile name is fetched from Back end and returned
    ${profile_name}    get current profile name via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]   ${profile_name}

I Get The Start Up Profile    #USED
    [Documentation]   The start up profile is fetched from back end and returned
    ${profile_details}    get profile details via personalization service     ${LAB_CONF}    ${CUSTOMER_ID}
    ${assigned_devices}   Extract Value For Key    ${profile_details}    ${EMPTY}   assignedDevices
    ${profile_id}   Extract Value For Key    ${assigned_devices}    deviceId:${CPE_ID}    defaultProfileId
    ${profile_name}   Extract Value For Key    ${profile_details}    profileId:${profile_id}     name
    [Return]   ${profile_name}

I Get The Profile Details From BO     #USED
    [Documentation]  The keyword get the profile details from BO
    ${customer_cpe_profile_json}   get profile details via personalization service    ${LAB_CONF}    ${CUSTOMER_ID}
    [Return]   ${customer_cpe_profile_json}

Get Favourite Channels Id Available For Current Profile        #USED
    [Documentation]    This keyword returns the favourite channels id list ${fetched_fav_list} for current profile
    ${profile_name}    get current profile name via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${fetched_fav_list}    get favourite channels Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}    ${profile_name}
    [Return]    ${fetched_fav_list}

I Get Available Genres For Profiles From BO    #USED
    [Documentation]  This keyword returns the list of available genres for profile creation
    ${genres}    get available genres    ${LAB_CONF}    ${OSD_LANGUAGE}
    [Return]    ${genres}

Get Customer Id From Personalization Service    #USED
    [Documentation]    This keyword returns the Customer Id for a device Id provided.
    ${customer_details}    get customer information by device id    ${LAB_CONF}    ${CPE_ID}
    ${customer_details_json}    Set Variable    ${customer_details.json()}
    ${customer_id}    Get From Dictionary    ${customer_details_json}    customerId
    Should Not Be Empty    ${customer_id}    Unable to fetch Customer Id from personalization service
    [Return]    ${customer_id}

I Create A New Profile Via Personalization Service    #USED
    [Documentation]  This keyword creates a profile for a customer and returns the profile id.
    [Arguments]    ${profile_name}    ${profile_color}
    ${profile_detail}    create profile    ${LAB_CONF}    ${CUSTOMER_ID}   ${profile_name}    ${profile_color}
    ${profile_detail_json}    Set Variable    ${profile_detail.json()}
    Should Not Be Empty   ${profile_detail_json}    Could not create a profile with name : ${profile_name} and color : ${profile_color}
    ${profile_id}    Get From Dictionary    ${profile_detail_json}    profileId
    [Return]  ${profile_id}
