*** Settings ***
Documentation     Common Detail Page keywords
Resource          ../Common/Common.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot
Library           ../../../Libraries/CustomLogger.py
#Resource          ../PA-15_VOD/VodGrid_Keywords.robot

*** Keywords ***
WebFeed Specific Teardown
    [Documentation]    Teardown steps for tests that need to Disable webFeed content
    Set WebFeedRecommendationOption Ui Config to false
    Default Suite Teardown

I activate Webfeed
    [Documentation]    Enable webFeed content
    Set WebFeedRecommendationOption Ui Config to true

Common Details Page elements are shown
    [Documentation]    This keyword verifies that all necessary and common elements on Details page are shown
    Error popup is not shown
    Wait Until Keyword Succeeds And Verify Status    10 times    1 sec    Detail page is not shown    I expect page contains 'id:DetailPage.View'
    Details Page Header is shown
    Title is shown
    Primary metadata is shown

Details Page Header is shown    #USED
    [Documentation]    Checks if Details Page Header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DETAILPAGE_INFO'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:watchingNow' contains 'textValue:^.+$' using regular expressions
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadTime' contains 'textValue:^.+$' using regular expressions
    ${time}    I retrieve value for key 'textValue' in element 'id:mastheadTime'
    Should Match Regexp    ${time}    ^[0-2][0-9]:[0-9][0-9]$

Title is shown      #USED
    [Documentation]    This is Generic keyword which asserts title is shown in detail page For LINEAR,REC,VOD,REPLAY
    ${text_title}    Run Keyword And Return Status    wait until keyword succeeds    8 times    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title' contains 'textValue:^.+$' using regular expressions
    ${image_title}    Run Keyword And Return Status    wait until keyword succeeds    8 times    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title' contains 'url:^.+$' using regular expressions
    Should be true    ${text_title} or ${image_title}    'Unable to verify event title in Details Page'

Poster is shown
    [Documentation]    This keyword asserts poster is shown in detail page
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:DetailPagePosterBackground::NodePosterBackground' contains 'url:.+detailedBackground.*' using regular expressions

'About' is shown
    [Documentation]    This keyword verifies if the 'About' is shown.
    wait until keyword succeeds    20 times    1 sec    I expect page contains 'textKey:DIC_PICKER_ABOUT'

Synopsis Episode is shown
    [Documentation]    This keyword verifies if the 'Synopsis' is shown.
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:synopsis-ItemDetails' contains 'textValue:^.+$' using regular expressions

Date of Episode is shown
    [Documentation]    This keyword verifies if the Date of Episode is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:episode_item_\\\\d+' contains 'textValue:^.+$' using regular expressions
    ${date_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_GENERIC_AIRING_DATE_FULL
    should be true    ${date_is_present}    Date of Episode is not shown

Primary metadata is shown    #USED
    [Documentation]    This keyword asserts primary metadata is shown in detail page
    wait until keyword succeeds    10 times    100 ms    I expect page element 'id:primaryMetadata' contains 'textValue:^.+$' using regular expressions

Press Back from SkyCinema
    [Documentation]    Press Back
    I Press    BACK

Actions menu is shown
    [Documentation]    This keyword asserts actions menu is shown in detail page
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'id:SectionNavigationScrollContainerdetailPageList'

Open Detail Page Of Event
    [Documentation]   This keyword opens the REC Details page
    I press    OK

Open Detail Page Of Event from Picker
    [Documentation]   This keyword opens the REC Details page

    I press    OK
    Details Page Header is shown


'Episodes' action is shown
    [Documentation]    This keyword asserts episodes option is shown
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'

'Episodes' action is not shown
    [Documentation]    This keyword asserts episodes option is not shown
    wait until keyword succeeds    10 times    300 ms    I do not expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'

Episode picker screen data is shown
    [Documentation]    This keyword verifies the episode picker data is shown.
    Episode picker is shown
    Poster is shown
    Title is shown
    Synopsis Episode is shown



I Open InfoPage Of Episode
    [Documentation]   Opens Info page from Episode picker

    I Press    OK


I Move Back To Previous Page
    [Documentation]    Navigates back

    I Press    BACK

Validate InfoPage From EpisodePicker
    [Documentation]   This keyword opens info page from Epi picker
    I Press    OK

Details Page Channel Logo is shown
    [Documentation]    This keyword asserts channel logo is shown in detail page
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:channelIconprimaryMetadata' contains 'url:.+\\\\.png*' using regular expressions

Details Page Channel Logo is not shown
    [Documentation]    This keyword asserts that channel logo is not shown in details page on Vod details page
    wait until keyword succeeds    10 times    1 s    I do not expect page contains 'id:channelIconprimaryMetadata'

Generic poster is shown
    [Documentation]    This keyword asserts a generic poster is shown on the Linear page for a recording in Saved
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:DetailPagePosterBackground::NodePosterBackground' contains 'url:.+detailedBackground.*' using regular expressions

Primary metadata is shown with generic poster
    [Documentation]    This keyword combines verification of Primary metadata and Generic poster on the Linear page
    ...    for a recording in Saved
    primary metadata is shown
    Generic poster is shown

Secondary metadata is shown
    [Documentation]    This keyword asserts secondary metadata is shown in detail page
    Move to element and assert    id:secondaryMetadata    textValue    ${EMPTY}    2    DOWN
    ${secondary_metadata}    I retrieve json ancestor of level '1' for element 'id:secondaryMetadata'
    ${secondary_metadata_count}    Get Length    ${secondary_metadata['children']}
    Should Not Be Equal As Integers    ${secondary_metadata_count}    0    Secondary metadata not found

'ABOUT THIS SERIES' action is displayed
    [Documentation]    This keyword asserts episodes option is shown
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_ACTIONS_ABOUT_SERIES'

'ABOUT THIS SERIES' action is not displayed
    [Documentation]    This keyword asserts episodes option is not shown
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'id:SectionNavigationListItem-0'
    ${id}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    textKey:DIC_ACTIONS_ABOUT_SERIES    id
    Should Be Equal    '${id}'    '${None}'    'ABOUT THIS SERIES' action is displayed

I focus 'ABOUT THIS SERIES' action
    [Documentation]    Navigate right until we highlight 'ABOUT THIS SERIES'
    ...    Pre-reqs: We have 'ABOUT THIS SERIES' on-screen
    Move Focus to Section    DIC_ACTIONS_ABOUT_SERIES    textKey

Non subscribed SVOD Applicable Actions are shown
    [Documentation]    This keyword checks all actions are currently shown on non entitled SVOD
    wait until keyword succeeds    10 times    300 ms    Non subscribed SVOD actions are in Json

Non subscribed SVOD actions are in Json
    [Documentation]    This keyword verifies that all non subscribed SVOD actions will be shown
    Get Ui Json
    ${subscribe_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_SUBSCRIBE
    ${episode_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_DETAIL_EPISODE_PICKER_BTN
    ${watchlist_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ADD_TO_WATCHLIST
    ${about_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ABOUT_SERIES
    Should be True    ${subscribe_action_visible} and ${episode_action_visible} and ${watchlist_action_visible} and ${about_action_visible}    SVOD actions are not shown

I open an unsubscribed SVOD boxset Episode Picker
    [Documentation]    This keyword opens the Episode Picker of an unsubscribed SVOD boxset
    I open 'SERIES'
    Move Focus to direction and assert    DOWN
    I navigate to unsubscribed boxset series svod tile
    I Press    OK
    I open episode picker

I open an unsubscribed SVOD TV Show Episode Picker
    [Documentation]    This keyword opens the Episode Picker of an unsubscribed SVOD TV Show
    ...    It opens a grid screen, navigates to the tile and then opens Episode Picker
    I open a grid screen
    I navigate to unsubscribed TV Show series svod tile
    I Press    OK
    I open episode picker

Non-entitled TVOD Applicable Actions are shown
    [Documentation]    This keyword checks all actions are currently shown on non entitled TVOD DP
    wait until keyword succeeds    10 times    300 ms    Non-entitled TVOD actions are in Json

Non-entitled TVOD actions are in Json
    [Documentation]    This keyword verifies that all Non entitled TVOD actions will be shown
    Get Ui Json
    ${rent_action}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_RENT_FROM
    ${episode_action}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_DETAIL_EPISODE_PICKER_BTN
    ${watchlist_action}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ADD_TO_WATCHLIST
    ${about_action}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ABOUT_SERIES
    Should be True    ${rent_action} and ${episode_action} and ${watchlist_action} and ${about_action}    Non entitled TVOD actions are not shown

I open an unsubscribed SVOD boxset Series Details Page
    [Documentation]    This keyword opens the Details Page of an unsubscribed SVOD boxset
    I open 'SERIES'
    Move Focus to direction and assert    DOWN
    I navigate to unsubscribed boxset series svod tile
    I Press    OK

I open a subscribed SVOD Boxset Series Details Page
    [Documentation]    This keyword opens the Details Page of a subscribed SVOD boxset
    I open 'SERIES'
    Move Focus to direction and assert    DOWN
    I navigate to subscribed boxset series svod tile
    I Press    OK

I open a non-entitled series TVOD boxset Episode Picker
    [Documentation]    This keyword opens the Episode Picker of a non entitled TVOD boxset
    I open a non-entitled series TVOD boxset show Details Page
    I open episode picker

I open a non-entitled series TVOD boxset show Details Page
    [Documentation]    This keyword opens a non entitled TVOD boxset show details page
    I open 'SERIES'
    Move Focus to direction and assert    DOWN
    I navigate to non-entitled boxset series tvod tile
    I Press    OK

I open a non-entitled series boxset show Details Page
    [Documentation]    This keyword opens a non entitled TVOD boxset show details page
    I press RIGHT 2 times
    I wait for 1 second
    I press DOWN 3 times
    I wait for 1 second
    I Press    OK
    I wait for 1 second

    I Press    OK


I open a non-entitled series discover show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    DISCOVER     textValue
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I Press    OK

I open a non-entitled discover show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    DISCOVER     textValue
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK

I open a non-entitled series discover show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    ONTDEK     textValue
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I Press    OK

I open a non-entitled SINTERKLAAS show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK

I open a non-entitled CATCHUP show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    CATCH UP     textValue
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT


    I Press    OK



I open a non-entitled channels show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    CHANNELS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    OK
    I wait for 2 second

    I Press    OK


I open a non-entitled kids show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    KIDS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK
    Details Page Header is shown

I open a non-entitled PROVIDERS show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    PROVIDERS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second

    I Press    OK

    I wait for 2 second
    I Press    OK
    I wait for 2 second

    I Press    INFO
    I wait for 2 second
    I Press    OK
    Details Page Header is shown


I open a non-entitled SHOWS show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    SHOWS     textValue
    I wait for 2 second
    I Press    DOWN
    I Press    DOWN
    I wait for 1 second
    I Press    RIGHT
    I wait for 2 second
    I Press    OK
    Details Page Header is shown



I open a non-entitled kids show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    KIDS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK


I open a non-entitled films show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    FILMS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK


I open a non-entitled Series show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    SERIES     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK


I open a non-entitled Alacarte show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD Alacarte show details page
    Move Focus to Section    A LA CARTE     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK

I open a non-entitled Zenders show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD Zenders show details page
    Move Focus to Section    ZENDERS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I wait for 2 second
    I Press    OK
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    OK


I open a non-entitled PlaySports show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD Zenders show details page
    Move Focus to Section    PLAY SPORTS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I wait for 2 second

    I Press    OK


I open a non-entitled Passion show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD Zenders show details page
    Move Focus to Section    PASSION     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    OK


I open a non-entitled BINNENKORT show Details Page BE
    [Documentation]    This keyword opens a non entitled TVOD BINNENKORT show details page
    Move Focus to Section    BINNENKORT     textValue
    I wait for 2 second
    I Press    DOWN
    I Press    OK


I open a non-entitled KINDER show Details Page
    [Documentation]    This keyword opens a non entitled TVOD KINDER show details page
    I focus KINDER
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK

I open a non-entitled HIGHLIGHTS show Details Page
    [Documentation]    This keyword opens a non entitled TVOD HIGHLIGHTS show details page
    I focus HIGHLIGHTS
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
     I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK

I open a non-entitled TVSERIEN show Details Page
    [Documentation]    This keyword opens a non entitled TVOD HIGHLIGHTS show details page
    I focus TVSERIEN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I Press    OK

I open a non-entitled CatchUpVOD show Details Page
    [Documentation]    This keyword opens a non entitled TVOD HIGHLIGHTS show details page
    I focus CatchUP_AT
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    OK
    I wait for 2 second
    I Press    OK

I open a non-entitled BoxSets show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    BOXSETS     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK


I open a non-entitled SkyCinema show Details Page
    [Documentation]    This keyword opens a non entitled TVOD discover show details page
    Move Focus to Section    SKY CINEMA     textValue
    I wait for 2 second
    I Press    DOWN
    I wait for 2 second
    I Press    RIGHT
    I Press    OK




I open an entitled series TVOD boxset Episode Picker
    [Documentation]    This keyword opens the Episode Picker of an entitled TVOD boxset
    I open a non-entitled series TVOD boxset show Details Page
    I rent the multioffer asset
    I Press    BACK
    I open episode picker

I Focus second Episode
    [Documentation]    This keyword focuses the Second Episode
    ...    Precondition: Episode Picker should be open.
    Move Focus to direction and assert    DOWN
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:episode_item_1'

First Episode is Focused
    [Documentation]    This keyword verifies that the First Episode is focused
    ...    Precondition: Episode Picker should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:episode_item_0'

Episode synopsis of First Episode is shown
    [Documentation]    keyword verifies if the 'Synopsis' of First Episode is shown
    ...    Precondition: Episode Picker should be open.
    wait until keyword succeeds    20 times    1 sec    I expect page contains 'id:synopsis-ItemDetails'
    ${synopsis_details}    I retrieve json ancestor of level '1' for element 'id:subTitleInfo-ItemDetails'
    ${synopsis_episode_item_0}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    id:titleNodeepisode_item_0    ${1}
    # use should be equal to support both simple & double quotes in the text value
    ${synopsis_first_episode}    Run keyword and return status    Should be Equal    ${synopsis_details['textValue']}    ${synopsis_episode_item_0['textValue']}
    [Return]    ${synopsis_first_episode}

I focus an episode from season Tab
    [Documentation]    This keyword focuses an episode from season Tab
    ...    and extracts the name of the episode from episode list
    Move Focus to direction and assert    RIGHT
    An Episode is focused
    ${node_id}    I retrieve value for key 'id' in focused element 'id:episode_item_\\d+' using regular expressions
    ${text_value_episode_item}    I retrieve value for key 'textValue' in element 'id:titleNode${node_id}'
    Set Test Variable    ${LAST_FETCHED_EPISODE_PICKER_ITEM}    ${text_value_episode_item}

I focus First Season
    [Documentation]    This keyword focuses the First Season
    ...    Precondition: Episode Picker should be open.
    Move Focus to direction and assert    LEFT
    ${has_about_tab}    run keyword and return status    Move Focus to Option in Value Picker    textKey:DIC_PICKER_ABOUT    UP    12
    Run keyword if    ${has_about_tab} == ${False}    Return from keyword
    ${focused_tab_id}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:titleNodeseason_item_\\d+$    id    ${True}
    ${_}    ${current_index}    split string from right    ${focused_tab_id}    _    1
    ${first_season_index}    Evaluate    ${current_index} + 1
    Move to element and assert    id:titleNodeseason_item_${first_season_index}    color    ${HIGHLIGHTED_OPTION_COLOUR}    5    DOWN

'About' item is Focused
    [Documentation]    This keyword checks that the 'About' item is focused
    option is focused in value picker    textKey:DIC_PICKER_ABOUT

I open a subscribed SVOD boxset Episode Picker
    [Documentation]    This keyword opens the Episode Picker of a subscribed SVOD boxset
    I open 'SERIES'
    Move Focus to direction and assert    DOWN
    I navigate to subscribed boxset series svod tile
    I Press    OK
    I open episode picker

I open a non-entitled VOD Details Page with a Trailer, More like this & WebFeed collections
    [Documentation]    This keyword opens the Detail page of an asset with Trailer
    ...    More like this and Webfeed Collections
    I Open 'MOVIES'
    I focus '${WEBFEED_TILE}' tile
    I press    OK

I open a VOD Details Page with a WebFeed collections
    [Documentation]    This keyword opens the Detail page of an asset with Webfeed Collections
    I Open 'MOVIES'
    I focus '${WEBFEED_MOVIES_TILE}' tile
    I press    OK

I open a non-entitled TVOD TV Show Episode Picker
    [Documentation]    This keyword opens the Episode Picker of a non entitled TVOD TV Show
    ...    It opens 'SERIES', navigates to the tile and then opens Episode Picker
    I open 'SERIES'
    I navigate to non-entitled TV Show series tvod tile
    I Press    OK
    I open episode picker

Subscribed SVOD Applicable Actions are shown
    [Documentation]    This keyword checks all actions are currently shown on entitled SVOD
    wait until keyword succeeds    10 times    300 ms    Subscribed SVOD actions are in Json

Subscribed SVOD actions are in Json
    [Documentation]    This keyword verifies that all subscribed SVOD actions will be shown
    Get Ui Json
    ${play_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_PLAY_FROM_START
    ${episode_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_DETAIL_EPISODE_PICKER_BTN
    ${watchlist_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ADD_TO_WATCHLIST
    ${about_action_visible}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ABOUT_SERIES
    Should be True    ${play_action_visible} and ${episode_action_visible} and ${watchlist_action_visible} and ${about_action_visible}    Entitled SVOD actions are not shown

An Episode is focused
    [Documentation]    This keyword verifies if an Episode is focused.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:episode_item_\\\\d+' using regular expressions

I Focus Second Season
    [Documentation]    This keyword focuses the Second Season
    ...    Precondition: Episode Picker should be open.
    Move Focus to direction and assert    LEFT
    ${down_status}    Run keyword and return status    Move Focus to Option in Value Picker    id:titleNodeseason_item_2    DOWN    4
    ${up_status}    Run keyword if    ${down_status} == ${False}    Run keyword and return status    Move Focus to Option in Value Picker    id:titleNodeseason_item_2    UP
    ...    4
    Should be true    ${down_status} or ${up_status}    could not find the second season

First Season is focused
    [Documentation]    This keyword verifies that the First Season is focused
    option is focused in value picker    id:titleNodeseason_item_1

I select the 'PLAY FROM START' action
    [Documentation]    This keyword focuses the 'PLAY FROM START' action in the VOD Details Page and selects it
    ...    Precondition: A VOD Details Page screen should be open.
    I wait for 5 second
    I press    OK
    I wait for 5 second
    I press    OK
    I focus the 'PLAY FROM START' action
    I press    OK
    I wait for 5 second


'Language settings' action is shown
    [Documentation]    This keyword checks the action 'Language settings' is shown on Detail Page with Multiple language
    wait until keyword succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS'

'REMOVE FROM WATCHLIST' action is shown
    [Documentation]    This keyword verifies that all elements of the 'Remove From Watchlist' action are shown.
    wait until keyword succeeds    10 times    1 sec    All elements of 'Remove From Watchlist' action are in Json

All elements of 'Remove From Watchlist' action are in Json
    [Documentation]    This keyword verifies that all elements related to
    ...    'Remove From Watchlist' action will be shown:
    ...    'Remove From Watchlist', 'Icon'
    Get Ui Json
    ${removed_from_watchlist_action_textkey}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_REMOVE_FROM_WATCHLIST
    ${removed_from_watchlist_iconkey}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    iconKeys:REMOVE_WATCHLIST
    Should be True    ${removed_from_watchlist_action_textkey} and ${removed_from_watchlist_iconkey}    Remove From Watchlist action elements are not shown

'ADD TO WATCHLIST' action is shown
    [Documentation]    This keyword verifies the 'ADD TO WATCHLIST' action is shown.
    wait until keyword succeeds    10 times    1 sec    All elements of 'ADD TO WATCHLIST' action are in Json

'WATCHLIST' action is shown
    [Documentation]    This keyword verifies the 'WATCHLIST' action is shown.
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_ACTIONS_(ADD_TO_WATCHLIST|REMOVE_FROM_WATCHLIST)' using regular expressions

I focus the 'ADD TO WATCHLIST' action
    [Documentation]    This keyword verifies the 'ADD TO WATCHLIST' action is shown and focuses it.
    ...    Precondition: A VOD Details Page screen should be open.
    'ADD TO WATCHLIST' action is shown
    Move Focus to Section    DIC_ACTIONS_ADD_TO_WATCHLIST    textKey

All elements of 'ADD TO WATCHLIST' action are in Json
    [Documentation]    This keyword verifies that all elements related to
    ...    'ADD TO WATCHLIST' action will be shown:
    ...    'ADD TO WATCHLIST', 'Icon'
    Get Ui Json
    ${add_to_watchlist_action_textkey}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ACTIONS_ADD_TO_WATCHLIST
    ${add_to_watchlist_icon_iconkey}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    iconKeys:ADD_WATCHLIST
    Should be True    ${add_to_watchlist_action_textkey} and ${add_to_watchlist_icon_iconkey}    Add To Watchlist action elements are not shown

'ADD TO WATCHLIST' Toast message is shown    #USED
    [Documentation]    This keyword verifies if the 'ADD TO WATCHLIST' Toast message is displayed.
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_FEEDBACK_MESSAGE_ADDED_TO_WATCHLIST'

'REMOVE FROM WATCHLIST' Toast message is shown
    [Documentation]    This keyword verifies if the 'REMOVE FROM WATCHLIST' Toast message is displayed.
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_FEEDBACK_MESSAGE_REMOVED_FROM_WATCHLIST'

More like this collection is available    #USED
    [Documentation]    This keyword asserts that the More like this Collection is available
    Move Focus to Collection with tile type    MoreLikeThis_tile
    I expect page contains 'textKey:DIC_COLLECTION_MORE_LIKE_THIS'

Webfeed content collection is available
    [Documentation]    This keyword asserts that the Webfeed content Collection is available
    Move Focus to Collection with tile type    webFeedCollection_tile
    I expect page contains 'textKey:DIC_COLLECTION_RELATED_WEB_CONTENT'

I select on a WebFeed collection Tile
    [Documentation]    This keyword focuses a WebFeed collection Tile and opens it
    Move Focus to Collection with tile type    webFeedCollection_tile
    I expect focused elements contains 'id:webFeedCollection_tile_0'
    I Press    OK

Synopsis is shown on the Detail Page
    [Documentation]    This keyword asserts the synopsis is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:description'

Time of Event is Shown
    [Documentation]    This keyword asserts the Time of Event is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:detailedInfoprimaryMetadata'

NOW is shown on the Detail Page
    [Documentation]    This keyword asserts the NOW is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_AIRING_TIME_NOW'

Date of Expiry is Displayed
    [Documentation]    This keyword asserts the Availble Until is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SECONDARY_META_AVAILABILTY_WITH_YEAR'

Replay ICON is Displayed
    [Documentation]    This keyword asserts replay icon is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:G'

Common VOD boxset Details Page elements are shown
    [Documentation]    This keyword verifies that all necessary and common elements in VOD BOXSET
    ...    Details page are shown
    Common Details Page elements are shown
    VOD Boxset 'Asset Subtitle' is shown
    More like this collection is available
    Secondary metadata is shown

VOD Boxset 'Asset Subtitle' is shown
    [Documentation]    This keyword asserts VOD Boxset Asset Subtitle is shown in detail page
    wait until keyword succeeds    10sec    ${JSON_RETRY_INTERVAL}    I expect page element 'id:seriesInfo' contains 'textKey:DIC_GENERIC_EPISODE_LONG_SEASON'

I select 'Remove from watchlist' in a Detail Page
    [Documentation]    This keyword focuses the 'Remove from Watchlist' action and presses OK.
    ...    Precondition: A Details Page screen should be open.
    Move Focus to Section    DIC_ACTIONS_REMOVE_FROM_WATCHLIST    textKey
    I Press    OK
    'remove from watchlist' toast message is shown

I Open Detail Page    #USED
    [Documentation]    This is a Generic Keyword To Open detail page Once any Selected Asset
    ...    This Keyword is applicable for Recording|VOD|Replay|Linear
    I Press    OK
    I wait for 2 second
    Details Page Header is shown


Handle Watch Popup Screens Before Playout Of Any Asset    #USED
    [Documentation]    This keyword handles any watch popup and select "Play from Start"
    ...    For e.g., DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE with
    ...    "Je video duurt langer dan de resterende huurtijd. Je video zal vroeger stoppen."
    I focus 'Play from start'
    I press    OK
    wait until keyword succeeds    2s    100 ms    I do not expect page contains 'id:interactiveModalPopup'

Play Any Asset From Detail Page    #USED
    [Documentation]    This Keyword Starts Playout For any asset From details page
    ...   This Keyword is applicable for Recording|VOD|Replay|Linear
    I press    OK
    ${status}    run keyword and return status    'Rent' interactive modal is shown
    Run Keyword If    ${status}    I press    OK
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin
    Handle Watch Popup Screens Before Playout Of Any Asset




Poster Is Shown In DetailPage    #USED
    [Documentation]    This keyword asserts poster is shown in detail page
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:DetailPagePosterBackground::NodePosterBackground' contains 'url:.+detailedBackground.*' using regular expressions
    ${url}    I retrieve value for key 'url' in element 'id:DetailPagePosterBackground::NodePosterBackground'
    Validate Detailpage Poster    ${url}

I Validate Recommendation Availability And Title Of Tiles    #USED
    [Documentation]    This Keyword Validates The More Like This Collection In VOD DetailPage
    More like this collection is available
    Content is available in More like this
    ${RETVAL}    I retrieve value for key 'data' in focused element 'id:moreLikeThisCollection'
    Log    ${RETVAL}
    @{LIST_OF_ITEMS}    Set Variable    ${RETVAL['items']}
    :FOR    ${ITEM}    IN    @{LIST_OF_ITEMS}
    \    Should Not Be Equal    ${ITEM['title']}    None
    \    Should Not BE Equal    ${ITEM['id']}    None

I Open Random Tile in More Like This And Validate Primary Info    #USED
    [Documentation]    Focus the random tile under More like this and validate basic elements
    ${tiles_container}    I retrieve json ancestor of level '1' for element 'id:MoreLikeThis_sub_0'
    ${tiles_count}    Get Length    ${tiles_container['children']}
    Should Be True    ${tiles_count} > 0    There are no Tiles displayed in 'More Like This' Section.
    ${random_tile}    Evaluate    random.sample(range(${tiles_count}), 1)    random
    ${random_tile}    Set Variable    ${random_tile[0]}
    ${position}    Evaluate    ${random_tile} % 2
    ${recommended_asset}    Set Variable    ${tiles_container['children'][${random_tile}]['children'][0]['children'][${1}]['textValue']}
    ${tile_found}    Run Keyword And Return Status    Move to element and assert    id:MoreLikeThis_focusRectangle_${position}_primaryTitle    textValue    ${recommended_asset}    ${tiles_count-1}    RIGHT
    ${tile_color_found}    Run Keyword If    not ${tile_found}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    textValue:${recommended_asset}    color
    Should Be True    ${tile_found}    Unable to navigate to Tile at position '${random_tile}' in 'More Like This' Section.'
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Common Details Page elements are shown

I Validate Synopsis Shown In '${page_name}' Details Page       #USED
    [Documentation]    This keyword asserts the synopsis is shown in Linear/ Recording details page and validates the value with backend
    ...     Possible Values for page_name are Linear/Recording.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:description'
    ${synopsis_displayed}    I retrieve value for key 'textValue' in element 'id:description'
    ${synopsis_key}     Set Variable If     '${page_name}' == 'Recording'       shortSynopsis       shortDescription
    ${synopsis}     Extract value for key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    ${synopsis_key}
    Run Keyword If     '''${synopsis}'''=='''${None}'''    Should Be Empty     ${synopsis_displayed}    Synopsis displayed '${synopsis_displayed}' did not match with the one in Asset details '${synopsis}'
    ...    ELSE   Should Be Equal    ${synopsis_displayed}    ${synopsis}    Synopsis displayed '${synopsis_displayed}' did not match with the one in Asset details '${synopsis}'

I Validate Year Of Production Shown In Details Page    #USED
    [Documentation]    This keyword verifies that the Year of production of the asset is shown in Recording Details Page primary metadata
    ${text_value}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'
    ${asset_prod_year}    Extract value for key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    yearOfProduction
    ${clean_text_value}    remove html tag from string    ${text_value}
    ${has_prod_year}    Evaluate    ${asset_prod_year} != None
    Run Keyword If      ${has_prod_year}     Should Match Regexp    ${clean_text_value}    [^\\d]${asset_prod_year}[^\\d]    Missing Year of production in Primary Metadata

Verify Title Shown       #USED
    [Documentation]    This keyword asserts the title shown in details page matches with asset details
    ${title_displayed}    I retrieve value for key 'textValue' in element 'id:title'
    ${title}     Extract value for key    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${EMPTY}    title
    should be equal as strings    ${title_displayed}    ${title}    Title displayed did not match with the one in Asset details

I Validate Title Shown In Details Page       #USED
    [Documentation]    This keyword asserts the title is shown and validates the value with backend
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:description'
    ${text_title}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title' contains 'textValue:^.+$' using regular expressions
    ${image_title}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title' contains 'url:^.+$' using regular expressions
    Run Keyword If      ${text_title}       Verify Title Shown
    Should be true    ${text_title} or ${image_title}

I select 'All Episode' in Detail Page
    [Documentation]  This keyword selects ALl Episode in Detail Page
    Move Focus to Section    DIC_DETAIL_EPISODE_PICKER_BTN    textKey
    I press  OK

I Validate Genre In Detail Page Of Replay Event    #USED
    [Documentation]    This keyword validates the Genre in details page of Replay event
    ...   Precondition: The 'FILTERED_REPLAY_EVENT' variable must have been set before.
    Variable Should Exist    ${FILTERED_REPLAY_EVENT}    Variable 'FILTERED_REPLAY_EVENT' is not set.
    Set Suite Variable    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${FILTERED_REPLAY_EVENT}
    Genre and Subgenre are shown in Primary metadata

Press Back
    [Documentation]  This keyword press back on any page
    I press  BACK

I Validate 'My Recordings' Is Displayed In Screen Player
    [Documentation]  This Keyword Validates 'My Recordings' in Screen Player

    I Press    OK
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:watchingNow' contains 'dictionnaryValue:My recordings'
    Video Player bar is shown


I Validate 'My Recordings' Is Displayed In Screen Player UK
    [Documentation]  This Keyword Validates 'My Recordings' in Screen Player
    I wait for 3 second

    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:watchingNow' contains 'dictionnaryValue:My recordings'
    Video Player bar is shown


#******************************CPE PERFORMANCE*********************************************

Details Page is Shown
    [Documentation]    Checks if Details Page is Shown
    [Arguments]     ${skip_metadata_check}=False
    ${json_object}    Get Ui Json
    #Verify if the screen is DetailPage.View
    ${detailpage_view_result}    Is In Json    ${json_object}    ${EMPTY}    id:DetailPage.View
    Should be true    ${detailpage_view_result}    Details Page View not shown
    #Verify More like this
#    ${more_like_this_result}    Is In Json    ${json_object}    ${EMPTY}    id:MoreLikeThis_tile_[\\d]+_poster
#    ...    ${EMPTY}    ${True}
#    Should be true    ${more_like_this_result}    More Like this is not shown
    #Verify if asset title is displayed
    ${title_img_result}    Is In Json    ${json_object}    id:title    image:^.+$    ${EMPTY}    ${True}
    ${title_text_result}    Is In Json    ${json_object}    id:title    textValue:^.+$    ${EMPTY}    ${True}
    Should be true    ${title_img_result} or ${title_text_result}   Title is not shown
    ${poster_result}    Is In Json    ${json_object}    id:DetailPagePosterBackground::NodePosterBackgroundImage
    ...    image:^.+$    ${EMPTY}    ${True}
    Should be true    ${poster_result}    Poster is not shown
    return from keyword if    ${skip_metadata_check}
    #Verify if asset synopsis is displayed
    #${synopsis_result}    Is In Json    ${json_object}    id:description    textValue:^.+$    ${EMPTY}    ${True}
    #Should be true    ${synopsis_result}   Synopsis not present
    #Verify if asset primary metadata is displayed. Checks run time and year of release
    ${primary_metadata}    Extract Value For Key    ${json_object}    id:detailedInfoprimaryMetadata    textValue
    ${clean_primary_metadata}    remove html tag from string    ${primary_metadata}
    ${text_key}    Extract value for key    ${json_object}    id:detailedInfoprimaryMetadata    textKey
    ${tag_to_use}    Set Variable If    "${text_key}" == "DIC_GENERIC_DURATION_HRS_MIN"     DIC_GENERIC_DURATION_HRS_MIN    "${text_key}" == "DIC_GENERIC_DURATION_MIN"    DIC_GENERIC_DURATION_MIN
    Run Keyword If  "${tag_to_use}" == "DIC_GENERIC_DURATION_HRS_MIN"    Should Match Regexp    ${clean_primary_metadata}
    ...    [\\d]+ h [\\d]+ min.*    Primay Metadata not present
    Run Keyword If  "${tag_to_use}" == "DIC_GENERIC_DURATION_MIN"    Should Match Regexp    ${clean_primary_metadata}
    ...    [\\d]+ min.*    Primay Metadata not present
    #Verify if poster is displayed


Episode picker is shown
    [Documentation]    This keyword verifies the episode picker data is shown.
    Get Ui Json
    Log    ${LAST_FETCHED_JSON_OBJECT}
    ${all_episodes_result}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    id:titleNodeepisode_item_[\\d]+
    ...   ${EMPTY}    ${True}
    Should be true    ${all_episodes_result}    All episodes are not listed
    ${view_is_episode_picker}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    id:EpisodePicker.View
    ${tab_node}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    id:titleNodeseason_item_\\d+    textKey:(DIC_EP_PICKER_EPISODES_TAB|DIC_EP_PICKER_SPECIALS|DIC_GENERIC_SEASON_NUMBER|DIC_GENERIC_EPISODE)    ${1}    ${EMPTY}
    ...    ${True}
    ${tab_has_content}    Is In Json    ${tab_node}    ${EMPTY}    textValue:.+    ${EMPTY}    ${True}
    ${title_has_content}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:title-ItemDetails    textValue:.+   ${EMPTY}    ${True}
    ${title_has_image}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:title-ItemDetails    image:.+    ${EMPTY}    ${True}
    Should be True    ${view_is_episode_picker} and ${tab_has_content} and (${title_has_content} or ${title_has_image})    Episode Picker data is missing content

Check If Season Selected Is '${season_number}', Otherwise Navigate To It Using Maximum Action '${max_season_navigation}'   #USED
    [Documentation]    This keyword gets the ui index of specified Season using season_number and navigates to it.
    Episode picker is shown
    ${required_season_id}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    textValue:(Season|Series) ${season_number}    id
    ...    ${True}
    Should Be True    '${required_season_id}' != '${None}'    Unable to locate 'Season ${season_number}' in Season Tab
    ${is_season_focused}    Run Keyword And Return Status    option is focused in value picker    ${required_season_id}
    Run Keyword If     not ${is_season_focused}    I Focus Season    ${required_season_id}    ${max_season_navigation}
    Run Keyword If     not ${is_season_focused}    I Press    OK

Verify Focused Episode In Episode Picker Page      #USED
    [Arguments]    ${selected_episode_title}    ${episode_show_title}
    [Documentation]    This Keyword checks if the currently focused episode is episode picker page is ${selected_episode_title}
    Episode picker is shown
    ${episode_selected_in_ui}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:subTitleInfo    textValue
    ${episode_selected}    Run Keyword And Return Status    Should Contain    ${episode_selected_in_ui}    ${selected_episode_title}
    ${selected_episode_show_title_in_ui}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:title-ItemDetails    textValue
    ${episode_show_title_displayed}    Run Keyword And Return Status    Should Contain    ${selected_episode_show_title_in_ui}    ${episode_show_title}
    ${episode_selected}    Evaluate    ${episode_selected} and ${episode_show_title_displayed} and '${episode_show_title}' != '${None}'
    [Return]  ${episode_selected}

I Focus Episode With Details        #USED
    [Arguments]    ${episode_list_title}    ${episode_show_title}    ${max_episode_navigation}
    [Documentation]    This Keyword navigates to the specified episode selected_episode
    ...   Prerequisite : Corresponding season of episode is selected in Episode Picker
    ${is_episode_selected}    Verify Focused Episode In Episode Picker Page    ${episode_list_title}    ${episode_show_title}
    ${episode_action}    Run Keyword If    ${max_episode_navigation} != ${1} and not ${is_episode_selected}    Get Episode Action For Navigation    ${episode_list_title}
    ...    ELSE    Set Variable    UP
    :FOR    ${INDEX}    IN RANGE    ${max_episode_navigation}
    \    ${is_episode_selected}    Verify Focused Episode In Episode Picker Page    ${episode_list_title}    ${episode_show_title}
    \    Exit For Loop If    ${is_episode_selected}
    \    I press    ${episode_action}
    Should Be True    ${is_episode_selected}    Unable to Navigate to Episode With title ${episode_show_title} in Episode Picker Page

Get Episode Action For Navigation    #USED
    [Arguments]    ${episode_list_title}
    [Documentation]    This keyword returns the action to be taken to navigate to  ${episode_list_title} in refeerence to the current episode selected
    Episode picker is shown
    ${current_ep_id}    I retrieve value for key 'id' in focused element 'id:episode_item_\\d+' using regular expressions
    ${current_index}       Get Regexp Matches    ${current_ep_id}    \\d+
    ${required_ep_id}    I retrieve value for key 'id' in element 'textValue:.*${episode_list_title}.*' using regular expressions
    ${required_index}       Get Regexp Matches    ${required_ep_id}    \\d+
    ${required_index_length}    Get Length    ${required_index}
    ${current_index_length}    Get Length    ${current_index}
    ${current_index}    Set Variable If    ${current_index_length} > 0    ${current_index[0]}    None
    ${required_index}    Set Variable If    ${required_index_length} > 0    ${required_index[0]}    None
    ${action}    Run Keyword If    ${required_index_length} == 0 or ${current_index_length} == 0   Set Variable    DOWN
    ...    ELSE IF    ${current_index} == ${required_index}    Set Variable    DOWN
    ...    ELSE IF    ${current_index} < ${required_index}    Set Variable    DOWN
    ...    ELSE    Set Variable    UP
    [Return]    ${action}

Handle Pin Popup    #USED
    [Documentation]    This keyword checks for pin entry pop-up. If pop-up is present then it will enter the pin and unlock the event.
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin

I Focus All Episode        #USED
    [Documentation]    This Keyword moves focus to all episodes
    ${all_episode_shown}    run keyword and return status     I expect page element 'id:ProvidersDP_title' contains 'textKey:DIC_SOURCES_AVAILABLE_ON'
    run keyword if  not(${all_episode_shown})
    ...    Move Focus to Section    DIC_DETAIL_EPISODE_PICKER_BTN    textKey
    ...    ELSE    run keyword
    ...    I press    DOWN

Extract Episode name from Recording
    [Documentation]    Split the Recording name and fetch only Episode part
    [Arguments]    ${SAVED_RECORDINGS_SERIES_ASSET}
    log    ${SAVED_RECORDINGS_SERIES_ASSET}
    @{SAVED_RECORDINGS_SERIES_ASSET}    Split String    ${SAVED_RECORDINGS_SERIES_ASSET}    -
    ${SAVED_RECORDINGS_SERIES_ASSET}    Set Variable    @{SAVED_RECORDINGS_SERIES_ASSET}[1]
    log    ${SAVED_RECORDINGS_SERIES_ASSET}
    [Return]    ${SAVED_RECORDINGS_SERIES_ASSET}

Invoke the Episode Picker
    [Documentation]    Navigate to the episode picker of VOD asset and verify the contents
    ${all_episode_shown}    run keyword and return status     I expect page element 'id:EPISODES' contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'
    run keyword if    ${all_episode_shown}   run keywords
    ...   I Focus All Episode
    ...   AND     I Press    OK
    ...   AND     log action    OpenEpisodePicker
    ...   AND     wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Episode picker is shown
    ...   AND     log action    OpenEpisodePicker_Done
    ...   AND     I Press    OK
    ...   AND     log action    OpeningInfoPage
    ...   AND     wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Details Page is Shown
    ...   AND     log action  OpeningInfoPage_Done