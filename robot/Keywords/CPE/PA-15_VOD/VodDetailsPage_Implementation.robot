*** Settings ***
Documentation     Vod Detail Page Implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../CommonPages/DetailPage_Keywords.robot

*** Keywords ***
Wait for Details page elements    #USED
    [Documentation]    This keyword verifies that any of the VOD Details Page elements are shown.
    Wait Until Keyword Succeeds    5 times    1s    I expect page contains 'id:DetailPagePosterBackground'
    ${json_object}    Get Ui Json
    ${rent_for_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT
    ${rent_from_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT_FROM
    ${rental_time_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_SECONDARY_META_RENTAL_REMAINING
    ${play_from_start_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_PLAY_FROM_START
    ${watch_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_WATCH
    ${watch_again_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_WATCH_AGAIN
    ${subscribe_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_SUBSCRIBE
    ${play_from_start_series_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_GENERIC_EPISODE_NUMBER
    ${is_vod}    Evaluate    True if (${rent_for_presence} or ${rental_time_presence} or ${rent_from_presence} or ${play_from_start_presence} or ${subscribe_presence} or ${watch_presence} or ${watch_again_presence} or ${play_from_start_series_presence}) else False
    Should Be True    ${is_vod}

VOD Detail Page is not shown
    [Documentation]    This keyword verifies that the VOD Details Page is not shown.
    I do not expect page contains 'id:DetailPage.View'

'Rent for' option is focused
    [Documentation]    This keyword verifies if the 'Rent for' action is focused on the contextual Menu popup.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Check if 'Rent for' option is focused

I select valid rent option
    [Documentation]    This keyword focuses any valid rent option for the current asset and selects it,
    ...    verifying an interactive Modal Popup appears.
    I focus any rent option
    I press    OK
    wait until keyword succeeds    5 times    100 ms    Layer is not empty    CURRENT_POPUP_LAYER    ${False}

I focus any rent option    #USED
    [Documentation]    This keyword focuses any of the existing rent options in the Details Page.
    ${rental_action}    wait until keyword succeeds    5s    100ms    Get any rent option available in details page
    Move Focus to Section    ${rental_action}    textKey

Get any rent option available in details page    #USED
    [Documentation]    This keyword verifies if any rent option is available in the Details Page,
    ...    and returns ${EMPTY} or the relevant json tag.
    ${json_object}    Get Ui Json
    ${rent_for_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT
    ${rent_from_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT_FROM
    ${rental_tag_to_use}    set variable if    ${rent_for_presence}    DIC_ACTIONS_RENT    ${rent_from_presence}    DIC_ACTIONS_RENT_FROM    ${EMPTY}
    should not be empty    ${rental_tag_to_use}    No rental option found
    [Return]    ${rental_tag_to_use}

Get duration from focused rental option
    [Documentation]    This keyword returns the duration in seconds of the expiry of the asset from its Details Page.
    ${rental_container}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I retrieve json ancestor of level '2' in element 'textKey:DIC_GENERIC_CURRENCY_FORMAT' for element 'color:#${HIGHLIGHTED_OPTION_COLOUR}' using regular expressions
    ${rental_string}    set variable    ${rental_container['textValue']}
    ${json_object}    get ui json
    ${is_sd_option_listed}    Is In Json    ${json_object}    ${EMPTY}    textValue:.*SD .*\-.*(EUR|€)    ${EMPTY}    ${True}
    ${is_hd_option_listed}    Is In Json    ${json_object}    ${EMPTY}    textValue:.*HD .*\-.*(EUR|€)    ${EMPTY}    ${True}
    ${is_4k_option_listed}    Is In Json    ${json_object}    ${EMPTY}    textValue:.*4K .*\-.*(EUR|€)    ${EMPTY}    ${True}
    ${video_format_string}    set variable if    ${is_sd_option_listed}    SD    ${is_hd_option_listed}    HD    ${is_4k_option_listed}
    ...    4K    ${EMPTY}
    @{splitted_string_fore}    Split String    ${rental_string}    separator=, ${video_format_string}
    @{splitted_string_back}    Split String    @{splitted_string_fore}[1]    separator=\-
    ${duration_string}    set variable    @{splitted_string_back}[0]
    ${timedelta}    Convert Time    ${duration_string}    timedelta
    ${wait_duration_to_expire}    set variable    ${timedelta.total_seconds()}
    [Return]    ${wait_duration_to_expire}

I enter a valid pin ensuring the rental process succeeds    #USED
    [Documentation]    This keyword verifies a purchase PIN entry popup is being shown,
    ...    enters a valid pin, and automatically handles any popup screens that require further validation.
    I enter a valid pin for VOD Rent
    I handle watch popup screens in ordering rental asset

I handle any warning screens in ordering rental asset
    [Documentation]    This keyword handles any popup screens that require further validation
    ...    For e.g., DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE with
    ...    "Je video duurt langer dan de resterende huurtijd. Je video zal vroeger stoppen."
    ${status}    run keyword and return status    wait until keyword succeeds    2 times    100 ms    Interactive modal is shown
    return from keyword if    ${status}==False
    wait until keyword succeeds    2s    100 ms    I expect page contains 'textKey:DIC_GENERIC_BTN_CONTINUE'
    Move Focus to Button in Interactive Modal    textKey:DIC_ACTIONS_WATCH    DOWN    1
    I press    OK
    wait until keyword succeeds    2s    100 ms    I do not expect page contains 'id:interactiveModalPopup'

I handle watch popup screens in ordering rental asset    #USED
    [Documentation]    This keyword handles any watch popup and select "Play from Start"
    ...    For e.g., DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE with
    ...    "Je video duurt langer dan de resterende huurtijd. Je video zal vroeger stoppen."
    ${status}    run keyword and return status    wait until keyword succeeds    2 times    100 ms    Interactive modal is shown
    return from keyword if    ${status}==False
    wait until keyword succeeds    2s    100 ms    I expect page contains 'textKey:DIC_ACTIONS_WATCH'
    Move Focus to Button in Interactive Modal    textKey:DIC_ACTIONS_PLAY_FROM_START    DOWN    2
    I press    OK
    wait until keyword succeeds    2s    100 ms    I do not expect page contains 'id:interactiveModalPopup'

I select the 'RENT FROM' action
    [Documentation]    This keyword focuses the 'RENT FROM' action in the VOD Details Page and selects it
    ...    Precondition: A VOD Details Page screen should be open.
    I focus the 'RENT FROM' action
    I press    OK

I focus the 'RENT FROM' action
    [Documentation]    This keyword verifies the 'RENT FROM' action is shown and focuses it.
    ...    Precondition: A VOD Details Page screen should be open.
    'RENT FROM' action is shown
    Move Focus to Section    DIC_ACTIONS_RENT_FROM    textKey

I rent the multioffer asset
    [Documentation]    This keyword rents the first option of an asset with multiple rent options through the Details Page.
    ...    Precondition: A VOD Details Page screen should be open.
    I select the 'RENT FROM' action
    'Rent' interactive modal is shown
    I press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    1s    I expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'
    I enter a valid pin for VOD Rent

'Rent' interactive modal is shown
    [Documentation]    This keyword verifies the interactive modal menu showing Rent options is shown.
    Interactive modal is shown
    ${json_object}    Get Ui Json
    ${rent_title_is_present}    Is In Json    ${json_object}    id:interactiveModalPopupTitle    textKey:DIC_GENERIC_RENT    ${EMPTY}
    ${currency_is_present}    Is In Json    ${json_object}    id:interactiveModalPopupBody    textKey:DIC_GENERIC_CURRENCY_FORMAT    ${EMPTY}
    should be true    ${rent_title_is_present}    The modal is not a Rent modal
    should be true    ${currency_is_present}    The modal has no Rent options

I focus the 'SUBSCRIBE' action
    [Documentation]    This keyword verifies the 'SUBSCRIBE' action is shown and focuses it.
    ...    Precondition: A VOD Details Page screen should be open.
    'SUBSCRIBE' action is shown
    Move Focus to Section    DIC_ACTIONS_SUBSCRIBE    textKey

'SUBSCRIBE' action is shown
    [Documentation]    This keyword verifies the 'SUBSCRIBE' action is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_SUBSCRIBE'

I Navigate To Watch Trailer Option    #USED
    [Documentation]    This keyword verifies if watch trailer option is available in the Details Page or not.
    ...    and returns whether the option was found or not
    :FOR    ${section_name}    IN RANGE    0    10
    \    ${json_object}    Get Ui Focused Elements
    \    ${cast_crew_collection}    Extract Value For Key    ${json_object}    id:CastAndCrewCollection_tile_0    data
    \    ${is_valid}    Run Keyword And Return Status    Should Not Be Empty    ${cast_crew_collection}
    \    ${tile_title}    Run Keyword If    ${is_valid}    Extract Value For Key    ${cast_crew_collection}    ${EMPTY}    title
    ...    ELSE    Set Variable    ${EMPTY}
    \    Should Not Be Empty    ${tile_title}    cast and crew collection has no title
    \    ${trailer_presence}    Run Keyword If    ${is_valid}    Run Keyword And Return Status    Should Be Equal As Strings    ${tile_title}    trailer    ignore_case=True
    \    Run Keyword If    not ${is_valid} or not ${trailer_presence}     I Press    DOWN
    \    ${trailer_found}    set variable if  ${trailer_presence}    ${True}    ${False}
    \    Exit For Loop If    ${trailer_found}
    [Return]    ${trailer_found}

Verify Presence Of Toast Message    #USED
    [Documentation]    Verifies presence of toast message while trailer playback
    sleep    5s
    ${popup_check}    Get Ui Focused Elements
    ${popup_presence}    Is In Json    ${popup_check}    ${EMPTY}    id:toast.accept
    run keyword if    ${popup_presence}    I Press    RIGHT
    run keyword if    ${popup_presence}    I Press    OK
    [Return]    ${popup_presence}

I Play The Trailer And Perform Post Playback Steps   #USED
    [Documentation]    This keywords plays the trailer performs pin entry if needed and checks that 'Continue Watching'
    ...    is not present. Precondition: Focus should be on trailer option in VOD details page
    I Press    OK
    sleep    2s
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    id:pinEntryModalPopupTitle
    run keyword if    ${result}    I enter a valid pin
    wait until keyword succeeds    5times    1s    I do not expect page element 'id:interactiveModalPopupTitle' contains 'textKey:DIC_ACTIONS_WATCH' using regular expressions

Verify And Exit Trailer Playback    #USED
    [Documentation]    This keyword initiates playback of a trailer and verifies the presence of toast message
    Wait Until Keyword Succeeds    5times    1s    I do not expect page contains 'id:Widget.ModalPopup'
    ${popup_presence}    Verify Presence Of Toast Message
    Should Be True    ${popup_presence}    'Toast message is not present'
    I press    STOP
    Wait Until Keyword Succeeds And Verify Status    5times    1s    Did not exit trailer playback properly
    ...    I expect focused element 'id:CastAndCrewCollection_tile_0' contains 'title:trailer'

Validate VOD Recommendation    #USED
    [Documentation]    This Keyword Validates The More Like This Collection In VOD DetailPage 
    More like this collection is available
    Content is available in More like this
    ${RETVAL}    I retrieve value for key 'data' in focused element 'id:MoreLikeThis'
    Log    ${RETVAL}
    @{LIST_OF_ITEMS}    Set Variable    ${RETVAL['items']}
    :FOR    ${ITEM}    IN    @{LIST_OF_ITEMS}
    \    Should Not Be Equal    ${ITEM['title']}    None
    \    Should Not BE Equal    ${ITEM['id']}    None

Try To Unlock Age Rated VOD Asset    #USED
    [Documentation]    This Keyword validate pipentry popup of age restricted asset and handle watchpopup if any
    I press    OK
    I Enter A Valid PIN On Age Rated Pin Entry Popup
    I handle watch popup screens in ordering rental asset

I Handle Watch Popup Screens And Any Warning Screen For Already Purchased VOD Asset    #USED
    [Documentation]    This keyword handles any watch popup and select "Play from Start"
    ...    For e.g., DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE with
    ...    "Je video duurt langer dan de resterende huurtijd. Je video zal vroeger stoppen."
    ${limited_entitlement}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 times    1s
    ...    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE'
    Run Keyword If    ${limited_entitlement}    I Press    OK
    ${status}    Run Keyword And Return Status    wait until keyword succeeds    2 times    100 ms    Interactive modal is shown
    Return From Keyword If    ${status}==False
    Wait Until Keyword Succeeds    2s    100 ms    I expect page contains 'textKey:DIC_ACTIONS_WATCH'
    Move Focus to Button in Interactive Modal    textKey:DIC_ACTIONS_PLAY_FROM_START    DOWN    2
    I press    OK

Try To Play Any VOD Asset From Detail Page    #USED
    [Documentation]    This Keyword validate pipentry popup of Rental/age restricted asset and handle watchpopup if any
    First Action Is Focused
    I press    OK
    ${status}    Run Keyword And Return Status    'Rent' interactive modal is shown
    Run Keyword If    ${status}    I press    OK
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin

Check Default Poster For Selected '${title}' Asset    #USED
    [Documentation]     This keyword validate that selected asset $(title} should not have default poster
    ${image_container}    I retrieve json ancestor of level '2' for element 'textValue:^.*${title}' using regular expressions
    ${text_title}    Is In Json    ${image_container}    ${EMPTY}    image:^.*default_posters.*$    ${EMPTY}    ${True}
    Should Not Be True  ${text_title}

Verify That Description In Details Page Matches With Description Given    #USED
    [Documentation]    This keyword verifies that description of an asset provided is same as that of details page
    ...    Precondition: Details Page is opened
    [Arguments]    ${description}
    ${ui_json}    Get Ui Json
    ${description_vod_details}    Extract Value For Key    ${ui_json}    id:description    textValue    ${False}
    Should Be Equal As Strings    ${description}    ${description_vod_details}    Descriptions do not match
'Watch' interactive modal is shown  #Used
    [Documentation]    This keyword verifies the interactive modal menu showing Rent options is shown.
    Interactive modal is shown
    ${json_object}    Get Ui Json
    ${rent_title_is_present}    Is In Json    ${json_object}    id:interactiveModalPopupTitle    textKey:DIC_ACTIONS_CONTINUE_WATCHING    ${EMPTY}
    ${currency_is_present}    Is In Json    ${json_object}    id:interactiveModalPopupBody    textKey:DIC_ACTIONS_PLAY_FROM_START    ${EMPTY}
    should be true    ${rent_title_is_present}    The modal is not a Series modal
    should be true    ${currency_is_present}    The modal has no Series options

#*************************************CPE PERFORMANCE********************************************
Handle Popup And Play from Details Page
    [Documentation]   This keyword handles the pin entry and play from start
    [Arguments]    ${play_from_start}=${True}
    ${rent_status}    run keyword and return status     I expect page element 'id:WATCH_AND_ACCESS|RENT' contains 'textKey:DIC_ACTIONS_RENT.*' using regular expressions
    # ${lock_status}    run keyword and return status     I expect page element 'id:detailPage_lock' contains 'iconKeys:LOCK'
    ${lock_status}    run keyword and return status     I expect page element 'id:detailPage_lock|lockIconTag_episode_item_[\\d]' contains 'iconKeys:LOCK' using regular expressions

    ${continue_watching}    set variable    ${False}
#    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
#    @{continue_watching_list}    Get Continue Watching List    ${profile}
    @{continue_watching_id}    create list

    @{continue_watching_list}    Fetch all bookmarks for the profile    network-recording
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{continue_watching_list}
    \    ${title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    contentId
    \    Append To List    ${continue_watching_id}    ${title}

     @{continue_watching_list}    Fetch all bookmarks for the profile    vod
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{continue_watching_list}
    \    ${title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    contentId
    \    Append To List    ${continue_watching_id}    ${title}

     @{continue_watching_list}    Fetch all bookmarks for the profile    replay
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{continue_watching_list}
    \    ${title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    contentId
    \    Append To List    ${continue_watching_id}    ${title}

     @{continue_watching_list}    Fetch all bookmarks for the profile    local-recording
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{continue_watching_list}
    \    ${title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    contentId
    \    Append To List    ${continue_watching_id}    ${title}
    log    ${continue_watching_id}

    ${current_event_url_json}    I retrieve value for key 'background' in element 'id:DetailPagePosterBackground::NodePosterBackgroundImage'
    ${current_event_url}    Extract Value For Key    ${current_event_url_json}    ${EMPTY}    url
    @{words} =	Split String	${current_event_url}    /
    log to console    @{words}[6]
    ${current_event_id}    set variable  @{words}[6]
    ${continue_watching}    set variable if  '${current_event_id}' in ${continue_watching_id}    ${True}    ${False}
    log  ${continue_watching}

    I press    OK
    run keyword if    not(${continue_watching} or ${lock_status} or ${rent_status})    return from keyword
    I wait for 500 ms
    ${rent_quality_type}    run keyword and return status    I expect page element 'id:interactiveModalPopupTitle' contains 'textKey:DIC_GENERIC_RENT'
    run keyword if    ${rent_quality_type}    I press    OK
    ${age_lock_status}    run keyword and return status    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_AGE_LOCK'
    run keyword if    ${age_lock_status} or ${lock_status} or ${rent_status}     I enter a valid pin
    run keyword if    not ${continue_watching}    return from keyword
    run keyword if    ${play_from_start} and ${continue_watching}    I focus 'play from start'
    run keyword if    ${play_from_start}=='False' and ${continue_watching}    I Focus The 'Continue Watching' Action
    I press    OK