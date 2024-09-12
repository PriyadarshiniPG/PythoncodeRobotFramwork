*** Settings ***
Documentation     Vod Detail Page keywords
Resource          ../PA-15_VOD/VodDetailsPage_Implementation.robot

*** Keywords ***
Subscribed SVOD Specific Teardown
    [Documentation]    Teardown steps for tests that need to unsubscribe from VOD products
    delete products by feature    VOD    ${LAB_TYPE}    ${CPE_ID}
    Default Suite Teardown

VOD Details Page is shown    #USED
    [Documentation]    This keyword verifies that the VOD Details Page is shown.
    Common Details Page elements are shown
    Wait Until Keyword Succeeds    5 times    1s    Wait for Details page elements

Details Page of this episode is shown
    [Documentation]    This keyword verifies that the details page of the selected episode is shown
    VOD Details Page is shown
    Current episode with right number and title is shown in Asset subtitle

Current season number is shown in Asset subtitle
    [Documentation]    This keyword verifies that the season of the selected episode is shown
    ${text_value}    I retrieve value for key 'textValue' in element 'id:seriesInfo'
    ${split_text_value}    Split String    ${text_value}    separator=,
    ${season_title}    Strip String    ${split_text_value[0]}
    Should Match Regexp    ${LAST_FETCHED_ANOTHER_SEASON}    ${season_title}

Current episode with right number and title is shown in Asset subtitle
    [Documentation]    This keyword verifies that the episode number with the right title of the selected episode is shown
    ${text_value}    I retrieve value for key 'textValue' in element 'id:seriesInfo'
    ${split_text_value}    Split String    ${text_value}    separator=Ep
    ${episode_title}    Strip String    ${split_text_value[1]}
    Should Match Regexp    ${LAST_FETCHED_EPISODE_PICKER_ITEM}    Ep${episode_title}

I open VOD Detail Page    #USED
    [Documentation]    This keyword opens the VOD Details Page of the currently selected tile,
    ...    Precondition: VOD screen should be open and VOD collection is being browsed.
    I Press    INFO
    wait until keyword succeeds    10 times    1 sec    VOD Details Page is shown

I open Add To Watchlist    #USED
    [Documentation]    This keyword focuses the 'Add to Watchlist' action and presses OK,
    ...    Precondition: A Details Page screen should be open.
    I focus the 'ADD TO WATCHLIST' action
    I Press    OK
    'REMOVE FROM WATCHLIST' action is shown

I focus Rent for
    [Documentation]    This keyword verifies the RENT FOR action is present on the UI and focuses it.
    Move Focus to Section    DIC_ACTIONS_RENT    textKey

Rent for is focused
    [Documentation]    This keyword verifies if the 'Rent for' action is focused.
    Section is Focused    DIC_ACTIONS_RENT    textKey

I rent asset
    [Documentation]    This keyword rents an asset through the Details Page,
    ...    Precondition: A VOD Details Page screen should be open.
    I select valid rent option
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    1s    I expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'
    I enter a valid pin for VOD Rent

I focus 'Rent for' option
    [Documentation]    This keyword verifies the 'Rent for' option on the Contextual Key Menu is present,
    ...    and focuses it.
    ...    Precondition: VOD screen should be open and a VOD section is being browsed
    Wait Until Keyword Succeeds    20 times    1 s    I expect page contains 'textKey:DIC_ACTIONS_RENT'
    : FOR    ${i}    IN RANGE    ${5}
    \    ${node}    I retrieve value for key 'textStyle' in element 'textKey:DIC_ACTIONS_RENT'
    \    Exit For Loop If    '${node['color']}' == '${HIGHLIGHTED_OPTION_COLOUR}'
    \    I Press    DOWN
    'Rent for' option is focused

'RENT FROM' action is shown
    [Documentation]    This keyword verifies the 'RENT FROM' action is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_RENT_FROM'

I select the 'SUBSCRIBE' action
    [Documentation]    This keyword focuses the 'SUBSCRIBE' action in the VOD Details Page and selects it
    ...    Precondition: A VOD Details Page screen should be open.
    I focus the 'SUBSCRIBE' action
    I press    OK

Duration is shown in Primary metadata
    [Documentation]    This keyword verifies that the duration of the asset is shown in Details Page primary metadata
    ${primary_metadata}    I retrieve json ancestor of level '1' for element 'id:detailedInfoprimaryMetadata'
    ${text_key}    Extract value for key    ${primary_metadata}    ${EMPTY}    textKey
    #Should be Equal    ${text_key}    DIC_GENERIC_DURATION_HRS_MIN    Wrong text key
    ${tag_to_use}    Set Variable If    "${text_key}" == "DIC_GENERIC_DURATION_HRS_MIN"     DIC_GENERIC_DURATION_HRS_MIN    "${text_key}" == "DIC_GENERIC_DURATION_MIN"    DIC_GENERIC_DURATION_MIN
    Should Be True  "${tag_to_use}" != "{EMPTY}"    Wrong text key
    ${text_value}    Extract value for key    ${primary_metadata}    ${EMPTY}    textValue
    ${clean_primary_metadata}    remove html tag from string    ${text_value}
    Run Keyword If  "${tag_to_use}" == "DIC_GENERIC_DURATION_HRS_MIN"    Should Match Regexp    ${clean_primary_metadata}    [^\\d]\\d{1,2}[^\\d]    Missing Duration in Primary Metadata
    Run Keyword If  "${tag_to_use}" == "DIC_GENERIC_DURATION_MIN"    Should Match Regexp    ${clean_primary_metadata}    [^\\d]    Missing Duration in Primary Metadata

Genre and Subgenre are shown in Primary metadata    #USED
    [Documentation]    This keyword verifies that the Genre and Subgenre of the asset is shown in Details Page primary metadata
    ${text_value}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${is_vodscreen_response}    Run Keyword And Return Status    Variable Should Exist    ${TILE_CRID}
    ${asset_details}    Run Keyword If    ${is_vodscreen_response}    I Get Details Of A VOD Asset With Given Crid Id    ${TILE_CRID}    ${cpe_profile_id}
    ${asset_details}    Set Variable If    ${is_vod_screen_response}    ${asset_details}    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}
    ${asset_genres}    Extract Value For Key    ${asset_details}    ${EMPTY}    genres
    ${nb_genres}    Get Length    ${asset_genres}
    ${has_sub_genre}    Evaluate    ${nb_genres} > 1
    Run keyword if    ${nb_genres}>0    Should Match Regexp    ${text_value}    .*${asset_genres[0]}.*    Missing genre in Primary Metadata
    Run keyword if    ${has_sub_genre}    Should Match Regexp    ${text_value}    .*${asset_genres[1]}.*    Missing sub-genre in Primary Metadata

Year of production is shown in Primary metadata    #USED
    [Documentation]    This keyword verifies that the Year of production of the asset is shown in Details Page primary metadata
    ${text_value}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'
    ${asset_prod_year}    Extract value for key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    prodYear
    ${clean_text_value}    remove html tag from string    ${text_value}
    ${has_prod_year}    Evaluate    ${asset_prod_year} != None
    Run Keyword If      ${has_prod_year}     Should Match Regexp    ${clean_text_value}    [^\\d]${asset_prod_year}[^\\d]    Missing Year of production in Primary Metadata

Age rating is shown in Primary metadata    #USED
    [Documentation]    This keyword verifies that the Age rating of the asset is shown in Details Page primary metadata
    ${asset_age_rating}    Extract value for key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    ageRating
    I expect page element 'id:ageRatingIconprimaryMetadata' contains 'iconKeys:PARENTAL_RATING_${asset_age_rating}'

I select '${format}' asset rental
    [Documentation]    This keyword selects the asset of ${format} for rental
    ...    Precondition: Should be on the asset rental pop up screen having multiple asset formats for rental
    Move to element assert focused elements using regular expression    textValue:^${format}.*    8    DOWN
    I press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_GENERIC_RENT'

I Watch Trailer For The Selected Asset    #USED
    [Documentation]    This keyword attempts to select watch trailer option from the currently opened Details Page,
    ...    Precondition: A VOD Details Page screen should be open.
    ${trailer_presence}    I Navigate To Watch Trailer Option
    should be true    ${trailer_presence}    'Trailer option not present'
    run keyword if    ${trailer_presence}    I Play The Trailer And Perform Post Playback Steps

I Verify And Exit Trailer Playback    #USED
    [Documentation]    The keyword verifies trailer playback for a VOD asset and comes back to details page
    Verify And Exit Trailer Playback

I Try To Unlock Age Rated VOD Asset    #USED
    [Documentation]    This keyword validate whether age is shown in detailPage and try to unlock the selected age rated vod asset
    Age rating is shown in Primary metadata
    First action is focused
    Try To Unlock Age Rated VOD Asset

I Play Any VOD Asset From Detail Page    #USED
    [Documentation]     This Keyword try to play any VOD asset from detailpage that can be either TVOD, age restricted or asset with/without Bookmark
    VOD Details Page is shown
    First action is focused
    Try To Play Any VOD Asset From Detail Page
    I Handle Watch Popup Screens And Any Warning Screen For Already Purchased VOD Asset
    Run Keyword And Ignore Error    About to start screen is shown
    Error popup is not shown

Continue Watching Selected Asset From Detail Page    #USED
    [Documentation]    This keyword Handles age restricted pin entry popup,
    ...    rental popup and rental limit warning screen while selecting 'Continue Watching' whenever prompted
    Try To Play Any VOD Asset From Detail Page
    ${limited_entitlement}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 times    1s
    ...    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE'
    Run Keyword If    ${limited_entitlement}    I Press    OK
    ${continue_watching_present}    Run Keyword And Return Status    'Continue Watching' popup is shown
    Run Keyword If    ${continue_watching_present}    I select the 'Continue watching' action
    Wait Until Keyword Succeeds    5s    100 ms    I do not expect page contains 'id:interactiveModalPopup'
    Run Keyword And Ignore Error    About to start screen is shown
    Error popup is not shown

Verify That Description In Details Page Matches With Description '${asset_description}'    #USED
    [Documentation]    This keyword verifies that description of an asset provided is same as that of details page
    ...    Precondition: Details Page is opened
    Verify That Description In Details Page Matches With Description Given    ${asset_description}

I Validate Age Lock Of VOD Asset With Title '${vod_asset_title}'   #USED
    [Documentation]    This keyword verifies that age lock is shown for the given asset in vod catalogue
    ...    In watershed lane where there is no age restriction (BTS4 - 22:00-05:29), verifies that age lock is not shown
    ${is_bts4}    Run Keyword And Return Status    Variable Should Exist    ${CURRENT_WATERSHED_LANE_NO_AGE_RESTRICTION}
    ${movie_title}    Regexp Escape    ${vod_asset_title}
    ${movie_title}    Regexp Escape    ${movie_title}
    Run Keyword If    not ${is_bts4}    I expect page element 'textValue:^.*${movie_title}' contains 'iconKeys:LOCK' using regular expressions
    ...    ELSE    I do not expect page element 'textValue:^.*${movie_title}' contains 'iconKeys:LOCK' using regular expressions