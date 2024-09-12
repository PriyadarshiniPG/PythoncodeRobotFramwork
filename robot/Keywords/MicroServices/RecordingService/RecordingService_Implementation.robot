*** Settings ***
Documentation     Implementation Keywords for Recording Service
Resource          ../../MicroServices/DiscoveryService/DiscoveryService_Keywords.robot
Library           ../../../Libraries/MicroServices/RecordingService/

*** Variables ***

*** Keywords ***
Get Customer Collections via RecordingService
    [Arguments]    ${lab_conf}=${LAB_CONF}    ${customer_id}=${customer_id}
    [Documentation]    This keyword Get the Customer Collections via RecordingService and
    ...    [return]  response [response.status_code; response.reason; response.json()]
    ${response}    RecordingService.Get Customer Collections    ${lab_conf}    ${customer_id}
    [Return]    ${response}

Data Validation Get Customer Collections via RecordingService
    [Arguments]    ${response_data}=${response.json()}
    [Documentation]    This keyword does the data validation for
    ...    Get the Customer Collections via RecordingService
	Log    ${response_data}
	Fill failedReason    "RecordingService: Data Validation Get Customer Collections via RecordingService"
	@{Keys}    Get Dictionary Keys    ${response_data}
	Check Key In List    recordings    ${Keys}
	${recordings_data}    Set Variable    ${response_data["recordings"]}
	@{Keys_recordings}    Get Dictionary Keys    ${recordings_data}
	Check Key In List    total    ${Keys_recordings}
	Check Key In List    data    ${Keys_recordings}
	Check Key In List    size    ${Keys_recordings}
	Check Key In List    bookings    ${Keys}
	${length}    Get Length    ${recordings_data['data']}
	: FOR    ${index}    IN RANGE    0    ${length}
	\    @{dataKeys}    Get Dictionary Keys    ${recordings_data['data'][${index}]}
	\    Check Key In List    id    ${dataKeys}
	\    Check Data Regexp    ${recordings_data['data'][${index}]['id']}    ^.+$    id
	\    Check Key In List    title    ${dataKeys}
	\    Check Data Regexp    ${recordings_data['data'][${index}]['title']}    ^.+$    title
	\    Check Key In List    type    ${dataKeys}
	\    Check Data Regexp    ${recordings_data['data'][${index}]['type']}    ^.+$    type
	\    Check Key In List    channelId    ${dataKeys}
	\    Check Data Regexp    ${recordings_data['data'][${index}]['channelId']}    ^.+$    channelId
	${bookings_data}    Set Variable    ${response_data["bookings"]}
	@{Keys_bookings}    Get Dictionary Keys    ${bookings_data}
	Check Key In List    total    ${Keys_bookings}
	Check Key In List    data    ${Keys_bookings}
	Check Key In List    size    ${Keys_bookings}
	${length}    Get Length    ${bookings_data['data']}
	: FOR    ${index}    IN RANGE    0    ${length}
	\    @{dataKeys}    Get Dictionary Keys    ${bookings_data['data'][${index}]}
	\    Check Key In List    id    ${dataKeys}
	\    Check Data Regexp    ${bookings_data['data'][${index}]['id']}    ^.+$    id
	\    Check Key In List    title    ${dataKeys}
	\    Check Data Regexp    ${bookings_data['data'][${index}]['title']}    ^.+$    title
	\    Check Key In List    type    ${dataKeys}
	\    Check Data Regexp    ${bookings_data['data'][${index}]['type']}    ^.+$    type
	\    Check Key In List    channelId    ${dataKeys}
	\    Check Data Regexp    ${bookings_data['data'][${index}]['channelId']}    ^.+$    channelId
    Empty failedReason

Get All Recorded Recordings And Total Number For The Customer    #USED
    [Documentation]    This keyword returns the total number of recordings and the recording list available for customer
    #the limit set from CPE is 2147483647
    ${profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${response}    get recorded recordings    ${LAB_CONF}    ${CUSTOMER_ID}    ${OSD_LANGUAGE}    profile_id=${profile_id}    adult=false    limit=2147483647    cpe_id=${CPE_ID}
    Check Respond Status And failedReason    ${response}
    ${response_data}    Set Variable    ${response.json()}
    ${total_assets}    Set Variable    ${response_data['total']}
    Should be true    ${total_assets} > ${0}    No Recorded assets are available for User
    [Return]    ${response_data}    ${total_assets}

Check '${minimum_asset_duration}' For '${asset_details_duration}'    #USED
    [Documentation]    This Keyword Evaluates the asset duration based on requirement
    ...    return : result - Returns True or False based on the criteria of required asset duration
    ${required_duration}    Convert To Integer    ${minimum_asset_duration}
    ${asset_duration}    Convert To Integer    ${asset_details_duration}
    ${result}    Evaluate    ${asset_duration} >= ${required_duration}
    [Return]    ${result}

Check '${asset_details_duration}' between '${minimum_asset_duration}' and '${maximum_asset_duration}'   #USED
    [Documentation]    This Keyword Evaluates the asset duration based on requirement
    ...    return : result - Returns True or False based on the criteria of required asset duration
    ${minimum_duration}    Convert To Integer    ${minimum_asset_duration}
    ${maximum_duration}    Convert To Integer    ${maximum_asset_duration}
    ${asset_duration}    Convert To Integer    ${asset_details_duration}
    ${result}    Evaluate    ${asset_duration} >= ${minimum_duration} and ${asset_duration} <= ${maximum_duration}
    [Return]    ${result}

Get Random Recorded Asset Details Based On Filters    #USED
    [Documentation]    This is a query based Keyword which returns one Random Recorded asset details and total number of
    ...    recordings based on the filters provided
    ...    param : type - 3 possible values : 'single'|'show'|'season'|Default value is 'Any'
    ...    param : recording_state - possible values : 'recorded'|'planned'|'failed'|'partiallyRecorded'|'ongoing'
    ...    param : is_assetized - possible values : Any|True|False
    [Arguments]    ${type}=Any    ${recording_state}=Any    ${minimum_asset_duration}=600    ${maximum_asset_duration}=Any    ${isAdult}=Any    ${is_assetized}=Any
    ${relevent_asset_list}    ${total_assets}    Get All Relevant Recorded Asset Details Based On Filters    ${type}    ${recording_state}    ${minimum_asset_duration}    ${maximum_asset_duration}    ${isAdult}    ${is_assetized}
    ${relevent_asset_list_length}    Get Length    ${relevent_asset_list}
    ${recording_type}    Run Keyword If    ${is_assetized}    Set Variable    DVRAS
    ...    ELSE IF    '${is_assetized}'=='Any'    Set Variable    Any
    ...    ELSE    Set Variable    DVRRB
    Should Be True      ${relevent_asset_list_length}>${0}      Unable To Find ${recording_type} Recording Asset With Filters type=${type}, recording_state=${recording_state}, minimum_asset_duration=${minimum_asset_duration}, maximum_asset_duration=${maximum_asset_duration} and isAdult=${isAdult}
    ${random_asset}    Evaluate  random.choice($relevent_asset_list)  random
    Log    ${random_asset}
    [Return]    ${random_asset}    ${total_assets}

Check If Valid Asset Type       #USED
    [Arguments]    ${required_type}   ${asset_type}
    [Documentation]    This Keyword Evaluates the asset type based on requirement
    ...    return : result - Returns True or False based on the criteria of required asset type
    Log    ${asset_type}
    ${result}   Run Keyword If    '${required_type}' == 'series'    Evaluate    '${asset_type}' == 'season' or '${asset_type}' == 'show'
    ...    ELSE IF   '${required_type}' != 'Any'    Evaluate    '${asset_type}' == '${required_type}'
    ...    ELSE    Set Variable    True
    [Return]    ${result}

Get All Relevant Recorded Asset Details Based On Filters    #USED
    [Documentation]    This is a query based Keyword which returns all Recorded asset details and total number of
    ...    recordings based on the filters provided
    ...    param : type - 3 possible values : 'single'|'show'|'season'|Default value is 'Any'
    ...    param : recording_state - possible values : 'recorded'|'planned'|'failed'|'partiallyRecorded'
    ...    param : is_assetized - possible values : Any|True|False
    ...    param : recommendations - possible values : Any|True
    [Arguments]    ${type}=Any    ${recording_state}=Any    ${minimum_asset_duration}=600   ${maximum_asset_duration}=Any    ${isAdult}=Any    ${is_assetized}=Any    ${recommendations}=Any
    ${all_recordings}    ${total_assets}    Get All Recorded Recordings And Total Number For The Customer
    ${all_recordings_data}    Set Variable    ${all_recordings['data']}
    @{relevent_asset_list}    Create List
    :FOR    ${INDEX}    IN RANGE     ${total_assets}
    \    ${asset}    Set Variable    ${all_recordings_data[${INDEX}]}
    \    ${valid_asset_type}    Check If Valid Asset Type    ${type}    ${asset['type']}
    \    Run Keyword If    '${type}' != 'Any'    Continue For Loop If    not ${valid_asset_type}
    \    ${asset_id}    Set Variable If    '${asset['type']}' == 'season'    ${asset['showId']}    ${asset['id']}
    \    ${asset_details}    Run Keyword If    '${asset['type']}' == 'single'    Set Variable    ${asset}
    \    ...   ELSE    Get Most Relevant Episode Of Series    ${asset_id}    ${asset['channelId']}
    \    Run Keyword If    '${asset['type']}' != 'single'    Set To Dictionary    ${asset}    mostRelevantEpisode    ${asset_details}
    \    ${is_vaild_asset}    Filter Recording Assets Based On Broadcast Date    ${asset_details}    ${is_assetized}
    \    Run Keyword If    ${is_vaild_asset} == False    Continue For Loop
    \    ${contains_adult}    Set variable    ${asset_details['containsAdult']}
    \    Run Keyword If     '${isAdult}' != 'Any'    Continue For Loop If    '${contains_adult}' != '${isAdult}'
    \    ${recording_state_value}    Set variable    ${asset_details['recordingState']}
    \    Run Keyword If    '${recording_state}' != 'Any'    Continue For Loop If    '${recording_state_value}' != '${recording_state}' and not ('${recording_state}' == 'recorded' and '${recording_state_value}' == 'partiallyRecorded')
    \    ${asset_duration}    Set Variable    ${asset_details['duration']}
    \    ${is_duration_valid}    Set Variable    False
    \    ${is_duration_valid}   Run Keyword If    '${minimum_asset_duration}' != 'Any' and '${maximum_asset_duration}' == 'Any'   Check '${minimum_asset_duration}' For '${asset_duration}'
    \    Continue For Loop If    '${minimum_asset_duration}' != 'Any' and ${is_duration_valid} == False
    \    ${is_duration_valid}   Run Keyword If    '${minimum_asset_duration}' != 'Any' and '${maximum_asset_duration}' != 'Any'    Check '${asset_duration}' between '${minimum_asset_duration}' and '${maximum_asset_duration}'
    \    Continue For Loop If    '${minimum_asset_duration}' != 'Any' and ${is_duration_valid} == False
    \    ${asset_id}    Set Variable If    '${asset['type']}' == 'single'    ${asset_details['id']}    ${asset_details['episodeId']}
    \    ${asset_recommendations}    Run Keyword If    '${recommendations}' != 'Any'    Get All Recommendations For The Selected Asset    ${3}    ${asset_id}
    \    Run Keyword If    '${recommendations}' != 'Any'    Continue For Loop If    ${asset_recommendations}== None or len(${asset_recommendations})==0
    \    Append To List    ${relevent_asset_list}    ${asset}
    Log    ${relevent_asset_list}
    [Return]    ${relevent_asset_list}    ${total_assets}

Get Details Of Single Recording     #USED
    [Arguments]    ${recording_id}
    [Documentation]    This keyword returns the details of a single recording using the ${recording_id}
    ${response}    Get Details Of Recording    ${LAB_CONF}    ${CUSTOMER_ID}    ${recording_id}    ${OSD_LANGUAGE}    ${CPE_ID}
    [Return]    ${response.json()}

Filter Recording Assets Based On Broadcast Date    #USED
    [Arguments]    ${asset_details}    ${is_assetized}
    [Documentation]    This keyword returns the boolean after verifying if the asset qualifies based on the broadcast date
    ${asset_date}    robot.libraries.DateTime.Convert Date    ${asset_details['endTime']}    result_format=%m/%d/%Y
    ${cur_date}    robot.libraries.DateTime.Get Current Date    result_format=%m/%d/%Y
    ${date_diff}   robot.libraries.DateTime.Subtract Date From Date   ${cur_date}    ${asset_date}    verbose
    ...    date1_format=%m/%d/%Y    date2_format=%m/%d/%Y
    @{words}    Split String	${date_diff}	${SPACE}
    Remove Values From List   ${words}   -
    ${is_valid_asset}    Run Keyword If    '${is_assetized}'=='Any'    Set Variable    True
    ${is_valid_asset}    Run Keyword If    '${is_assetized}'=='True'    Evaluate    ${words[0]} > 6 and ${words[0]} < 90
    ...    ELSE    Set Variable    ${is_valid_asset}
    ${is_valid_asset}    Run Keyword If    '${is_assetized}'=='False'    Evaluate    ${words[0]} < 4
    ...    ELSE    Set Variable    ${is_valid_asset}
    [Return]    ${is_valid_asset}

Get Random Recording With Age Rating '${Age_Rating}' And '${Less}'    #USED
    [Documentation]    This Keyword Returns Random Age Rated Recoding With Age Rating Depending Upon Variable '${Less}'
    ...    If The Value Of Variable ${Less} Is True, Then It Returns Asset With Age Rating Given And Less And Vice-Versa
    ${all_recordings}    ${total_assets}    Get All Recorded Recordings And Total Number For The Customer
    ${all_recordings_data}    Set Variable    ${all_recordings['data']}
    ${age_rated_assets}    Create List
    :FOR    ${INDEX}    IN RANGE    ${total_assets}
    \    ${asset}    Set Variable    ${all_recordings_data[${INDEX}]}
    \    Log    ${asset}
    \    ${Age_Rated}   Run Keyword And Return Status    Dictionary Should Contain Key    ${asset}    minimumAge
    \    Continue For Loop If    '${Age_Rated}' != '${True}' or '${asset['type']}' != 'single'
    \    Continue For Loop If    '${asset['recordingState']}' == 'failed'
    \    Run Keyword If    '${Age_Rated}'=='${True}' and ${Age_Rating}<=${asset['minimumAge']} and '${Less}'!='${True}'    Append To List     ${age_rated_assets}       ${asset}
    \    ...    ELSE IF    '${Age_Rated}'=='${True}' and ${Age_Rating}>=${asset['minimumAge']} and '${Less}'=='${True}'    Append To List     ${age_rated_assets}       ${asset}
    ${age_rated_asset}    Get Random Element From Array    ${age_rated_assets}
    ${more_or_less}    Run Keyword If    '${Less}' == '${True}'    Set Variable    less
    ...    ELSE IF       '${Less}' != '${True}'    Set Variable    more
    ${failedReason}    Catenate    There are no recordings with age rating ${Age_Rating} or  ${more_or_less}
    Should Not Be Empty    ${age_rated_asset}    ${failedReason}
    [Return]    ${age_rated_asset}    ${total_assets}

Get Recording State Of All Recordings From BO   #USED
    [Documentation]  Returns the resording state of all the recordings from BO
    ${response}   get recording state for events   ${LAB_CONF}     ${CUSTOMER_ID}    ${CPE_ID}
    [Return]   ${response.json()}

Delete Oldest Recordings If The Quota Exceeds '${maximum_quota_percentage}' Percentage And Set Quota To '${recording_quota_threshold_percentage}' Percentage     #USED
    [Documentation]  This keyword is used to manage the recordings quota. It deletes old recordings if the occupied recording quota
    ...    exceeds ${maximum_quota_percentage} and set it to below ${recording_quota_threshold_percentage} percentage
    ...    param maximum_quota_percentage: This is the maximum occupied quota percentage CPE can have, beyond which oldest recordings will be deleted
    ...    param recording_quota_threshold_percentage: threshold Percentage to which Recordings Quota is to be set if the Quota percentage exceeds maximum_quota_percentage
    ${recording_quota}    Get Recording Percentage Via AS
    Return From Keyword If    ${recording_quota} == 0
    ${all_recordings}    ${total_assets}    Get All Recorded Recordings And Total Number For The Customer
    ${all_recordings_data}    Set Variable    ${all_recordings['data']}
    ${recording_exceeded_quota}    Run Keyword If    ${recording_quota}>${maximum_quota_percentage}    Evaluate    (${recording_quota}-${maximum_quota_percentage})*10
    ...    ELSE    Set Variable    0
    :FOR    ${INDEX}    IN RANGE    ${recording_exceeded_quota}
    \    ${recording_seconds_exceeded}    Delete Recordings Until Quota Reaches Threshold    ${all_recordings_data}    ${recording_exceeded_quota}    ${recording_quota_threshold_percentage}    ${total_assets}
    \    Exit For Loop If    ${recording_seconds_exceeded} <= 0
    \    ${all_recordings}    ${total_assets}    Get All Recorded Recordings And Total Number For The Customer
    \    ${all_recordings_data}    Set Variable    ${all_recordings['data']}
    ${recording_quota}    get_recordings_quota_via_as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Should Be True      ${recording_quota}<=${maximum_quota_percentage}      Unable To bring recording quota occupied duration to below ${maximum_quota_percentage}%

Delete Recordings Until Quota Reaches Threshold     #USED
    [Documentation]  This keyword loops through the recordings list and deletes assets until the recording quota reaches its threshold
    ...    It returns the total recording hours exceeded(according to threshold) after deleting the recording assets
    [Arguments]  ${all_recordings_data}    ${recording_exceeded_quota}    ${recording_quota_threshold_percentage}    ${total_assets}
    ${recording_type}    Run Keyword If    '${STB_TYPE}'=='HDD'    Set Variable    local-recording
    ...    ELSE    Set Variable    network-recording
    :FOR    ${INDEX}    IN RANGE    ${total_assets}
    \    Exit For Loop If    ${recording_exceeded_quota} <= 0
    \    ${asset_details}    Set Variable    ${all_recordings_data[${INDEX}]}
    \    ${asset_details}     Run Keyword If    '${asset_details['type']}'!='single'    Set Variable    ${asset_details['mostRelevantEpisode']}
    \    ...                  ELSE            Set Variable    ${asset_details}
    \    Run Keyword If    '${recording_type}'=='network-recording'    Delete Recording    ${LAB_CONF}    ${CUSTOMER_ID}    ${asset_details['id']}
    \    ...    ELSE    Delete Recording Via As    ${STB_IP}    ${CPE_ID}    ${asset_details['id']}
    \    Sleep    2
    \    ${quota_occupied}    Get Recording Percentage Via AS
    \    ${recording_exceeded_quota}    Evaluate    ${quota_occupied}-${recording_quota_threshold_percentage}
    [Return]   ${recording_exceeded_quota}

Get Recording Percentage Via AS    #USED
    [Documentation]  This keyword returns the percentage of recording available on the CPE via as
    ${recording_quota}    get_recordings_quota_via_as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${quota_occupied}    Convert To Number    ${recording_quota}
    [Return]    ${quota_occupied}

Get All Planned Recordings From BO    #USED
    [Documentation]  This keyword returns all the planned recordings from backend
    ${response}    execute get customers bookings    ${LAB_CONF}     ${CUSTOMER_ID}
    [Return]    ${response}

Schedule Recording For The Given Event    #USED
    [Documentation]  This keyword schedules recording for the given event
    [Arguments]    ${channel_id}    ${event_id}
    ${response}    schedule recording show    ${LAB_CONF}     ${CUSTOMER_ID}    ${event_id}    ${channel_id}
    [Return]    ${response}

Check '${recording_id}' Recording Is Not Listed In BO    #USED
    [Documentation]    This keyword gets the list of recording from BO and verifies that it does not have a recording with id '${recording_id}'
    ${all_recordings}    ${total_assets}    Get All Recorded Recordings And Total Number For The Customer
    ${all_recordings_data}    Set Variable    ${all_recordings['data']}
    @{relevent_asset_list}    Create List
    ${asset_found}    Set Variable    False
    :FOR    ${INDEX}    IN RANGE    ${total_assets}
    \    ${asset}    Set Variable    ${all_recordings_data[${INDEX}]}
    \    ${asset_found}    Evaluate   '${asset['id']}' == '${recording_id}'
    \    Exit For Loop If    ${asset_found}
    Should Be True    not ${asset_found}    Recording Asset With Id '${recording_id}' is listed in BO

Get All Episodes Of Show   #USED
    [Arguments]    ${show_id}    ${channelId}    ${source}
    [Documentation]  Returns All the episode recordings of specified show.
    ...    param source: take values recording|booking
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    #2147483647 is the limit specified in CPE for /episodes/shows API
    ${response}   Get List of Episodes Show    ${LAB_CONF}    ${CUSTOMER_ID}  ${profile}  ${show_id}   ${channelId}   ${OSD_LANGUAGE}  ${source}    ${CPE_ID}   2147483647
    Check Respond Status And failedReason    ${response}
    [Return]   ${response.json()}

Get All Episodes Of Season   #USED
    [Arguments]    ${season_id}    ${source}
    [Documentation]  Returns All the episode recordings of specified season
    ...    param source: take values recording|booking
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    #2147483647 is the limit specified in CPE for /episodes/seasons API
    ${response}   Get List of Episodes Season    ${LAB_CONF}    ${CUSTOMER_ID}  ${profile}  ${season_id}  ${OSD_LANGUAGE}  ${source}    2147483647
    Check Respond Status And failedReason    ${response}
    [Return]   ${response.json()}
