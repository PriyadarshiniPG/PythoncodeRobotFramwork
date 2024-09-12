*** Settings ***
Documentation     Linear Details Page implementation keywords
Resource          ../Common/Common.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot
Resource          ../PA-15_VOD/VodGrid_Keywords.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../CommonPages/DetailPage_Keywords.robot
Resource          ../../MicroServices/LinearService/LinearService_Keywords.robot
Resource          ../Common/ChannelTuning.robot
Library           Libraries.MicroServices.LinearService.LinearService

*** Variables ***
#UI Preference Audio/Subtitle Language Mapping to TextKEY value
${Off}            DIC_GENERIC_TOGGLE_BTN_OFF
${or}             Original
${ar}             DIC_SETTINGS_LANG_ARABIC
${bo}             DIC_SETTINGS_LANG_BOSNIAN
${zh}             DIC_SETTINGS_LANG_CHINESE
${hr}             DIC_SETTINGS_LANG_CROATIAN
${cs}             DIC_SETTINGS_LANG_CZECH
${da}             DIC_SETTINGS_LANG_DANISH
${nl}             DIC_SETTINGS_LANG_DUTCH
${et}             DIC_SETTINGS_LANG_ESTONIAN
${en}             DIC_SETTINGS_LANG_ENGLISH
${el}             DIC_SETTINGS_LANG_GREEK
${fi}             DIC_SETTINGS_LANG_FINNISH
${fr}             DIC_SETTINGS_LANG_FRENCH
${de}             DIC_SETTINGS_LANG_GERMAN
${he}             DIC_SETTINGS_LANG_HEBREW
${hi}             DIC_SETTINGS_LANG_HINDI
${hu}             DIC_SETTINGS_LANG_HUNGARIAN
${it}             DIC_SETTINGS_LANG_ITALIAN
${lv}             DIC_SETTINGS_LANG_LATVIAN
${lt}             DIC_SETTINGS_LANG_LITHUANIAN
${no}             DIC_SETTINGS_LANG_NORWEGIAN
${mt}             DIC_SETTINGS_LANG_MALTESE
${mk}             DIC_SETTINGS_LANG_MACEDONIAN
${pl}             DIC_SETTINGS_LANG_POLISH
${pt}             DIC_SETTINGS_LANG_PORTUGUESE
${ro}             DIC_SETTINGS_LANG_ROMANIAN
${ru}             DIC_SETTINGS_LANG_RUSSIAN
${sr}             DIC_SETTINGS_LANG_SERBIAN
${sk}             DIC_SETTINGS_LANG_SLOVAK
${es}             DIC_SETTINGS_LANG_SPANISH
${sv}             DIC_SETTINGS_LANG_SWEDISH
${tr}             DIC_SETTINGS_LANG_TURKISH
${ur}             DIC_SETTINGS_LANG_URDU
${arabic}         ar
${bosnian}        bo
${chinese}        zh
${croatian}       hr
${czech}          cs
${danish}         da
${dutch}          nl
${estonian}       et
${english}        en
${greek}          el
${finnish}        fi
${french}         fr
${german}         de
${hebrew}         he
${hindi}          hi
${hungarian}      hu
${italian}        it
${latvian}        lv
${lithuanian}     lt
${norwegian}      no
${maltese}        mt
${macedonian}     mk
${polish}         pl
${portuguese}     pt
${portuguese}     ro
${russian}        ru
${serbian}        sr
${slovak}         sk
${spanish}        es
${swedish}        sv
${turkish}        tr
${urdu}           ur
${standard}       DIC_SETTINGS_SUBTITLES_VALUE_STANDARD
${closed captions}    DIC_SETTINGS_SUBTITLES_VALUE_CC

*** Keywords ***
Read current event time from Linear Details Page
    [Documentation]    This keyword returns the time information of current event
    ...    Precondition: Linear Details Page is open
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:detailedInfoprimaryMetadata' contains 'textValue:^.+$' using regular expressions
    ${event_info}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'
    @{event_info}    split string    ${event_info}    •
    ${event_info}    strip string    @{event_info}[0]
    [Return]    ${event_info}

I open Details Page via Contextual Key Menu
    [Documentation]    This keyword opens Linear Details Page
    I Press    CONTEXT
    I select the 'Info' action
    Linear Details Page is shown

Linear Detail Page is not shown
    [Documentation]    This keyword asserts that Linear Detail Page is not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:DetailPage.View'

I focus Audio Language
    [Documentation]    This keyword focuses Audio language in Preferences screen in Settings
    Move Focus to Setting    textKey:DIC_SETTINGS_AUDIO_LANGUAGE_LABEL    DOWN    8

get channel name from logo element in channel bar
    [Documentation]    This keyword retrieves the channel name from logo element in Channel Bar
    ${ancestor}    get channel logo element ancestor from channel bar
    [Return]    ${ancestor['textValue']}

Compare event duration in '${view}' and traxis metadata
    [Documentation]    This keyword checks event duration shown in linear details page/Guide/Channel Bar matches with traxis metadata
    ...    Precondition: Linear Details Page/Guide/Channel Bar is open
    ${view}    convert to lowercase    ${view}
    ${event_time}    Run Keyword if    '${view}'=='linear detail page'    Read current event time from Linear Details Page
    ...    ELSE IF    '${view}'=='info panel'    Read current event time from Info Panel
    ...    ELSE IF    '${view}'=='channel bar'    Read current event time from Channel Bar
    ...    ELSE    FAIL    Keyword incorrect
    @{event_time}    split string    ${event_time}    -
    log    @{event_time}[0]
    log    @{event_time}[1]
    ${event_duration}    get time interval    @{event_time}[0]    @{event_time}[1]
    @{event_duration_metadata}    Read current event info from traxis metadata
    LOG    ${event_duration}
    LOG    @{event_duration_metadata}[3]
    should be equal as strings    @{event_duration_metadata}[3]    ${event_duration}

Read current event info from traxis metadata
    [Documentation]    This keyword returns the time information of current event from traxis metadata
    I open Channel Bar
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:nnchannelNumber' contains 'textValue:^.+$' using regular expressions
    ${channel_number}    I retrieve value for key 'textValue' in element 'id:nnchannelNumber'
    ${channel_id}    get channel id by number via ls    ${CITY_ID}    ${channel_number}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    @{event_info}    get current event    ${channel_id}    ${CPE_ID}
    [Return]    @{event_info}

I focus Set Reminder
    [Documentation]    This keyword focuses Set reminder option
    'SET REMINDER' action is shown
    Move Focus to Section    DIC_ACTIONS_SET_REMINDER    textKey

I focus Delete Reminder
    [Documentation]    This keyword focuses Delete reminder option
    Delete Reminder is shown
    Move Focus to Section    DIC_ACTIONS_DELETE_REMINDER    textKey

try to WATCH LIVE TV age rated programme
    [Documentation]    This keyword clicks on watch or continue watching on detail page
    ...    Precondition: Linear Detail Page should be open
    ${json_object}    Get Ui Json
    ${is_watch_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_WATCH
    ${watch_action_to_use}    set variable if    ${is_watch_present}    DIC_ACTIONS_WATCH    DIC_ACTIONS_CONTINUE_WATCHING
    Move Focus to Section    ${watch_action_to_use}    textKey
    I Press    OK
    run keyword if    ${is_watch_present}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I select 'Watch live TV'

Read current Genre/Subgenre from Info Panel
    [Documentation]    This keyword returns the current Genre/SubGenre from info panel
    ${genre_info}    I retrieve value for key 'textValue' in element 'id:detailedInfogridPrimaryMetadata'    # make language agonistic
    @{genre_info}    split string    ${genre_info}    •
    ${genre_info_text}    strip string    @{genre_info}[2]
    [Return]    ${genre_info_text}

Displayed Genre/SubGenre on info panel matches metadata
    [Documentation]    This keyword checks Genre/SubGenre shown in info panel matches with metadata
    ...    Precondition: Guide is open
    ${genre}    Read current Genre/SubGenre from info panel
    ${genre_metadata_traxis}    Read current Genre/SubGenre from traxis metadata
    ${genre_metadata_traxis}    strip string    ${genre_metadata_traxis}
    ${genre_metadata_from_dict}    get from dictionary    ${GENRE_SUBGENRE_DICTIONARY}    ${genre_metadata_traxis}
    should be equal as strings    ${genre}    ${genre_metadata_from_dict}

Read current Genre/SubGenre from traxis metadata
    [Documentation]    Returns the current Genre/SubGenre from traxis metadata
    ${channel_id}    Get current channel
    ${event_genre}    get current event genre    ${channel_id}    ${CPE_ID}
    [Return]    ${event_genre}

Read Actor Surname from Linear Detail Page
    [Documentation]    Returns actor surname from linear detail page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:castAndCrewString' contains 'textValue:^.+$' using regular expressions
    ${cast_crew_info}    I retrieve value for key 'textValue' in element 'id:castAndCrewString'
    @{cast_crew_info}    Split String    ${cast_crew_info}    Cast:
    @{cast_crew_info}    split string    @{cast_crew_info}[1]    ,
    ${cast_crew_info}    strip string    @{cast_crew_info}[0]
    @{cast_crew_info}    split string    ${cast_crew_info}    ${SPACE}
    ${actor_surname}    strip string    @{cast_crew_info}[1]
    [Return]    ${actor_surname}

Read Actor Surname from traxis metadata
    [Documentation]    Returns actor surname from traxis metadata
    ${channel_id}    Get current channel
    ${actor_surname}    get actor surname    ${channel_id}    ${CPE_ID}
    [Return]    ${actor_surname}

Read event start time from Linear Details Page
    [Documentation]    Returns the start time of current event.
    ...    Precondition: Linear Details Page is open
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:detailedInfoprimaryMetadata' contains 'textValue:^.+$' using regular expressions
    ${event_info}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'
    @{event_info}    split string    ${event_info}    •
    @{event_info}    split string    @{event_info}[0]    -
    ${event_start_time}    strip string    @{event_info}[0]
    [Return]    ${event_start_time}

Read event start time from traxis metadata
    [Documentation]    Returns event start time from traxis metadata
    ${channel_id}    Get current channel
    ${event_start_time}    get event start time    ${channel_id}    ${CPE_ID}
    [Return]    ${event_start_time}

Read country of origin from linear detail page
    [Documentation]    Returns country of origin value from linear detail page
    ${status}    Set Variable    ${False}
    ${limit}    Set Variable    ${5}
    : FOR    ${i}    IN RANGE    ${limit}
    \    ${json_object}    Get Ui Json
    \    ${is_section_focused}    Is In Json    ${json_object}    id:country0_secondaryMetadata    color:${INTERACTION_COLOUR}
    \    Exit For Loop If    '${is_section_focused}' == 'True'
    \    Press Key    DOWN
    ${country_of_origin}    I retrieve value for key 'textValue' in element 'id:country0_secondaryMetadata'
    [Return]    ${country_of_origin}

Read country of origin from traxis metadata
    [Documentation]    Returns country of origin value from traxis metadata
    ${channel_id}    Get current channel
    ${country_of_origin}    get country of origin    ${channel_id}    ${CPE_ID}
    [Return]    ${country_of_origin}

Read event start time from Channel Bar
    [Documentation]    Returns start time of the current event from channel bar
    Ongoing event is focused
    ${current_event_time}    Read current event time from Channel Bar
    @{event_info}    split string    ${current_event_time}    -
    ${event_start_time}    strip string    @{event_info}[0]
    [Return]    ${event_start_time}

Read current Genre/SubGenre from Linear Detail Page
    [Documentation]    This keyword returns the current Genre/SubGenre from linear detail page
    ${genre_info}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'    # make language agonistic
    @{genre_info}    split string    ${genre_info}    •
    ${status}    Run Keyword And Return Status    Evaluate    type(@{genre_info}[1])
    ${genre_linear_detail_page}    Set Variable If    ${status}    @{genre_info}[2]    @{genre_info}[1]
    ${genre_linear_detail_page}    strip string    ${genre_linear_detail_page}
    [Return]    ${genre_linear_detail_page}

Read Actors Name from Linear Detail Page
    [Documentation]    Returns actor first name from linear detail page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:castAndCrewString' contains 'textValue:^.+$' using regular expressions
    ${cast_crew_info}    I retrieve value for key 'textValue' in element 'id:castAndCrewString'
    @{cast_crew_list}    Split String    ${cast_crew_info}    Cast:
    ${actors_name}    Set Variable    @{cast_crew_list}[1]
    [Return]    ${actors_name}

Read Actor FirstName from traxis metadata
    [Documentation]    Returns actor first name from traxis metadata
    ${channel_id}    Get current channel
    ${event_info}    get current event    ${channel_id}    ${CPE_ID}
    ${event_id}    remove_string_using_regexp    ${event_info[0]}    (,imi.*)
    ${event_details}    get traxis event details    ${event_id}
    ${event_details_json}    evaluate    json.loads('''${event_details}''')    json
    ${event_info}    set variable    ${event_details_json['Title']['Actors']['Actor'][0]['Value'].strip()}
    ${event_info}    strip string    ${event_info}
    @{actor_firstname}    split string    ${event_info}    ,
    ${actor_firstname}    strip string    @{actor_firstname}[1]
    [Return]    ${actor_firstname}

Read Director FirstName from Linear Detail Page
    [Documentation]    Returns director first name from linear detail page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:castAndCrewString' contains 'textValue:^.+$' using regular expressions
    ${cast_crew_info}    I retrieve value for key 'textValue' in element 'id:castAndCrewString'
    @{match}    Get Regexp Matches    ${cast_crew_info}    (Directed by: )(\\w+)    2
    ${director_first_name}    Set Variable    @{match}
    [Return]    ${director_firstname}

Read Director FirstName from traxis metadata
    [Documentation]    Returns director first name from traxis metadata
    ${channel_id}    Get current channel
    ${event_info}    get current event    ${channel_id}    ${CPE_ID}
    ${event_id}    remove_string_using_regexp    ${event_info[0]}    (,imi.*)
    ${event_details}    get traxis event details    ${event_id}
    ${event_details_json}    evaluate    json.loads('''${event_details}''')    json
    ${event_info}    set variable    ${event_details_json['Title']['Directors']['Director'][0].strip()}
    ${event_info}    strip string    ${event_info}
    @{director_firstname}    split string    ${event_info}    ,
    ${director_firstname_metadata}    strip string    @{director_firstname}[1]
    [Return]    ${director_firstname_metadata}

Read season info from linear detail page
    [Documentation]    Returns season info from linear detail page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textKey:DIC_GENERIC_EP_NUMBER' contains 'textValue:^.+$' using regular expressions
    ${event_info}    I retrieve value for key 'textValue' in element 'id:seriesInfo'
    @{season_event_info}    split string    ${event_info}    -
    ${season_event_info}    strip string    @{season_event_info}[0]
    [Return]    ${season_event_info}

Read season info from traxis metadata
    [Documentation]    Returns season info from traxis metadata
    ${channel_id}    Get current channel
    ${event_info}    get current event    ${channel_id}    ${CPE_ID}
    ${event_info}    get event details from epg service    ${event_info[0]}    ${event_info[1]}    ${channel_id}    ${COUNTRY}    ${OSD_LANGUAGE}
    ${season_number}    set variable if    ${event_info['seasonNumber']} > 0    Season ${event_info['seasonNumber']}    ${None}
    ${episode_number}    set variable if    ${event_info['episodeNumber']} > 0    Ep ${event_info['episodeNumber']}    ${None}
    ${season_event_info}    Catenate    SEPARATOR=,${SPACE}    ${season_number}    ${episode_number}
    [Return]    ${season_event_info}

I select Delete Reminder
    [Documentation]    This keyword will delete an event reminder
    I focus Delete Reminder
    I Press    OK

Get id for the current and next events    #USED
    [Documentation]    This keyword retrieves the id for the current and next events
    ${json_object}    Get Ui Json
    ${index_id_now_on_tv}    Extract Value For Key    ${json_object}    textKey:DIC_GENERIC_AIRING_TIME_NOW    id
    ${index_id_now}    Replace String    ${index_id_now_on_tv}    nowBox    ${EMPTY}
    ${index_id_now}    Convert To Integer    ${index_id_now}
    #    Elements in Json use the 0 to 4 indexing. If the current index for    the NOW ON TV event is 4, then the next event would be a 0 since 4+1 == 5. Otherwise, it would be id+1
    ${index_id_next}    Evaluate    0 if ${index_id_now+1} == 5 else ${index_id_now+1}
    [Return]    ${index_id_now}    ${index_id_next}

Minutes left until the next event
    [Documentation]    This keyword checks minutes left until the next event (if less than 16 minutes)
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:extendedInfoText${INDEX_ID_NEXT}' contains 'textValue:Starts in' using regular expressions
    ${header}    I retrieve value for key 'textValue' in element 'id:extendedInfoText${index_id_next}'
    @{time_left_string}    Split String    ${header}    separator=${SPACE}
    ${next_event_in}    Set Variable    @{time_left_string}[2]
    ${next_event_in}    Strip String    ${next_event_in}
    [Return]    ${next_event_in}

Get time left until next event
    [Documentation]    This keyword gets the time left until the next event (less, equal or more than 16 minutes)
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:extendedInfoText${INDEX_ID}' contains 'textValue:^.+$' using regular expressions
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadTime' contains 'textValue:^.+$' using regular expressions
    ${json_object}    Get Ui Json
    ${header_1}    Extract Value For Key    ${json_object}    id:extendedInfoText${INDEX_ID}    textValue
    ${header_2}    Extract Value For Key    ${json_object}    id:mastheadTime    textValue
    @{regexp_match_1}    Get Regexp Matches    ${header_1}    (\\d{2}):(\\d{2}) ?- ?(\\d{2}):(\\d{2})    1    2    3
    ...    4
    ${current_event_time_end_hours}    ${current_event_time_end_minutes}    Set Variable    @{regexp_match_1[0]}[2]    @{regexp_match_1[0]}[3]
    ${current_event_time_end_hours}    Convert To Integer    ${current_event_time_end_hours}
    ${current_event_time_end_minutes}    Convert To Integer    ${current_event_time_end_minutes}
    @{regexp_match_2}    Get Regexp Matches    ${header_2}    (\\d{2}):(\\d{2})    1    2
    ${current_time_hours}    ${current_time_minutes}    Set Variable    @{regexp_match_1[0]}[0]    @{regexp_match_1[0]}[1]
    ${current_time_hours}    Convert To Integer    ${current_time_hours}
    ${current_time_minutes}    Convert To Integer    ${current_time_minutes}
    ${same_hour}    Evaluate    ${current_time_hours} == ${current_event_time_end_hours}
    ${current_event_duration_left}    Set Variable If    '${same_hour}' == 'False'    ${current_event_time_end_minutes + (60 - ${current_time_minutes})}    ${current_event_time_end_minutes - ${current_time_minutes}}
    [Return]    ${current_event_duration_left}

Waiting time until Starts in is displayed
    [Arguments]    ${time_left_until_next_event}
    [Documentation]    This keyword sets the waiting time until the 'Starts in...' is displayed in the channel bar
    ${waiting_time}    Set Variable    ${time_left_until_next_event - 14}
    Wait for ${waiting_time} minutes

Compare event name in channel bar and traxis metadata
    [Documentation]    This keyword checks event duration shown in linear details page/Guide/Channel Bar matches with traxis metadata.
    ...    Precondition: Channel Bar is open
    ${event_name}    Read current event name from Channel Bar
    @{event_info}    Read current event info from traxis metadata
    ${event_info_details}    Split string    ${event_info[0]}    ,
    ${event_id}    set variable    ${event_info_details[0]}
    ${event_details}    get traxis event details    ${event_id}
    ${event_details_json}    evaluate    json.loads('''${event_details}''')    json
    ${event_name_traxis}    set variable    ${event_details_json['Title']['Name'].strip()}
    ${event_name_traxis}    strip string    ${event_name_traxis}
    Should Contain    ${event_name_traxis}    ${event_name}    Event name from channel bar doesnt match with the traxis metadata

Read current event name from Channel Bar    #USED
    [Documentation]    Returns the current event name
    ...    Precondition: channel bar is open
    ${event_name}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:selectedProgramme'
    [Return]    ${event_name}

I mark '${channel_with_index}' as locked
    [Documentation]    This keyword sets the channel as user locked
    I focus '${channel_with_index}' channel
    ${status}    I check if '${channel_with_index}' channel has lock icon
    Run Keyword If    ${status} == ${False}    Run Keywords    I press    OK
    ...    AND    I press    BACK
    ...    ELSE    I press    BACK

I check if '${nth}' channel has lock icon
    [Documentation]    This keyword returns boolean value stating if a channel has a lock icon shown next to it on the list
    ${nth}    Evaluate    ${nth}-${1}
    ${json_object}    Get Ui Json
    ${is_locked}    Is In Json    ${json_object}    id:item-check-icon-${nth}    textValue:J
    [Return]    ${is_locked}

Reminder icon is set in details view
    [Documentation]    This keyword asserts that the reminder icon has been set in details view
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:reminderIconprimaryMetadata' contains 'textValue:P'

Exit To Current Channel View    #USED
    [Documentation]    This keyword exits to current channel view from any view
    I Press    MENU
    Make Sure That Remote Pairing Request Popup Is Exited
    ${child_application_layer}    I retrieve value for key 'children' in element 'id:MAIN_LAYER'
    ${current_view}    Extract Value For Key    ${child_application_layer}    ${EMPTY}    id
    Run Keyword If    '${current_view}' != 'FullScreen.View'    Press BACK until the current channel view is present

Get Random IP Channel Number
    [Documentation]    This keyword retrieves ID List of IP TV Channels, select one randomly and retrieves the
    ...    Channel Number of that random Channel ID selected
    ...    [Return]   Channel Number of a random IP TV Channel
    ${ip_channels}   I Fetch All IP Channels
    Log    IP TV - ip_channels List: ${ip_channels}
    ${channel_id}    Get Random Element From Array    ${ip_channels}
    Log    IP TV - channel_id: ${channel_id}
    ${channel_number}    get channel number by id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    Log    Replay TV - channel_number: ${channel_number}
    [Return]    ${channel_number}
