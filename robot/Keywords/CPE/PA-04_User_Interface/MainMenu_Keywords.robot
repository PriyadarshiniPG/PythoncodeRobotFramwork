*** Settings ***
Documentation     Keywords covering functions and aesthetic of the Main Menu bar
Resource          ../Common/Stbinterface.robot
Resource          ../Common/Common.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot
Resource          ../PA-06_TV_Guide/TVGuide_Keywords.robot
Resource          ../PA-26_Applications/Apps_Keywords.robot
Resource          ../PA-26_Applications/Apps_Implementation.robot

*** Keywords ***
I open Main Menu    #USED
    [Documentation]    Keyword to Open Main Menu via channel bar
    I open Channel Bar
    I Press    MENU
    Main Menu is shown

Main Menu is shown    #USED
    [Documentation]    Keyword to verify Main Menu is shown
    ${action_found}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    I expect page contains 'id:PersonalHome.View'
    Should Be True    ${action_found}    Unable to open Main Menu

Main Menu is not shown
    [Documentation]    Keyword to verify Main Menu is not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'PersonalHome.View'

I open Contextual Main Menu    #USED
    [Documentation]    Keyword to open Main Menu and confirm Contextual Main Menu is shown
    I open Main Menu
    Contextual Main Menu is shown
    Skip Error popup

Contextual Main Menu is shown
    [Documentation]    Keyword to verify Contextual Main Menu is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:contextualMainMenu'

I open Contextual main menu highlighting Search
    [Documentation]    Open Contextual Main Menu and highlight Search
    I open Contextual Main Menu
    I focus Search
    Search is focused

The interaction color for '${highlighted_tab}' is set to '${expected_color}'
    [Documentation]    Keyword to verify the highlighted tab shows the expected color.
    should be true    '${expected_color}'=='${INTERACTION_COLOUR_NAME}'    Unexpected color ${expected_color} specified for ${highlighted_tab} screen
    ${key_to_search}    set variable if    '${highlighted_tab}'=='TV Guide'    textKey:DIC_MAIN_MENU_TV_TV    INVALID
    should not be true    '${key_to_search}'=='INVALID'    Unexpected tab ${highlighted_tab} specified for keyword
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element '${key_to_search}' contains 'color:${INTERACTION_COLOUR}'

I open Contextual main menu highlighting Guide
    [Documentation]    Keyword to open Contextual Main Menu and highlight Guide
    I open Contextual Main Menu
    I focus TV Guide
    Guide is focused

I focus Search
    [Documentation]    Keyword to focus Search on Main menu
    Move Focus to Section    SEARCH    iconKeys

I focus Settings
    [Documentation]    Keyword to focus Settings on Main menu
    Move Focus to Section    SETTINGS    iconKeys

Search is focused
    [Documentation]    Keyword to verify Search is focused
    Section is Focused    SEARCH    iconKeys

I open Search through Main Menu
    [Documentation]    Keyword to open Search through Main Menu
    I open Main Menu
    I open Search

I open Search
    [Documentation]    Keyword to open Search screen
    I focus Search
    I Press    OK
    Search screen is shown

Search screen is shown
    [Documentation]    Keyword to verify Search screen is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:keyboard-key-2-12-OnScreen*' using regular expressions

I open Guide through Main Menu    #USED
    [Documentation]    Keyword to open Guide through Main Menu
    I open Main Menu
    I open Guide

I open Guide
    [Documentation]    Keyword to open Guide
    I focus TV Guide
    I Press    OK
    Guide is shown

I focus TV Guide
    [Documentation]    Focuses TV Guide by checking the highlighted section and moving RIGHT until TV Guide is reached
    Move Focus to Section    DIC_MAIN_MENU_TV_TV    textKey

Guide is shown
    [Documentation]    Keyword to verify Guide is shown
    wait until keyword succeeds    5 times    1 s    I expect page contains 'id:Guide.View'
    wait until keyword succeeds    5 times    1 s    Verify guide programme cell data is loaded
    ${guide_block_id}    Get guide block ID
    Set Test Variable    ${LAST_FOCUSED_GUIDE_BLOCK}    ${guide_block_id}

I open guide '${times}' times
    [Documentation]    Opens guide '${times}' times
    : FOR    ${_}    IN RANGE    ${times} - 1
    \    I Press    GUIDE
    \    Guide is shown
    \    Exit to current channel view
    I Press    GUIDE
    Guide is shown

Verify guide programme cell data is loaded
    [Documentation]    This keyword verifies if the programme cell data is loaded
    ${json_object}    Get Ui Json
    ${programme_cell_value}    Extract Value For Key    ${json_object}    id:block_\\d+_event_.*    textValue    ${True}
    should not be equal as strings    ${programme_cell_value}    None    Guide programme cell data is not loaded

Guide is focused
    [Documentation]    Keyword to check Guide is focused
    Section is Focused    DIC_MAIN_MENU_TV_TV    textKey

I focus Replay TV
    [Documentation]    Keyword to focus Replay TV in main menu
    Move Focus to Section    DIC_MAIN_MENU_TV_REPLAY    textKey

I open Apps through Main Menu       #USED
    [Documentation]    Keyword to open Apps through Main Menu
    I open Main Menu
    I open Apps

On Demand is focused
    [Documentation]    Keyword to check On Demand is focused
    Section is Focused    DIC_MAIN_MENU_MOVIES_AND_SERIES    textKey

Most popular searches are shown
    [Documentation]    Keyword to verify the Most popular searches label is present
    Wait Until Keyword Succeeds    10sec    0s    I expect page element 'id:contextualMainMenu-navigationContainer-SEARCH_title_0' contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_POPULAR_SEARCH'

First tile in contextual main menu is focused    #USED
    [Documentation]    This keyword checks if the first tile in contextual main menu is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:contextualMainMenu-navigationContainer-TVGUIDE_element_0'

UI is being shown
    [Documentation]    This keyword verifies the UI is present for the STB by looking for the Main Menu, the Tips
    ...    and Tricks screen, or opening the Channel Bar and checking it is present.
    ${tips_tricks_present}    Is Tips and Tricks present
    ${main_menu_present}    Run Keyword And Return Status    Main Menu is shown
    return from keyword If    ${tips_tricks_present} or ${main_menu_present}    ${None}
    I open Channel Bar
    Channel Bar is present

First Tile In Contextual Menu Under TV Apps Is Focused    #USED
    [Documentation]    First tile under TV Apps is focused in Contextual Menu.
    I open Main Menu
    I focus Apps
    I Press   DOWN

Validate Contextual Main Menu Of On Demand    #USED
    [Documentation]    This Keyword Validates CMM Of On Demand as per country
    I focus On Demand
    On Demand is focused
    Recommended For You Is Shown
    Recently Added Is Shown


Naviagate To Random VOD Asset Detailpage From Contextual MainMenu Of On Demand    #USED
    [Documentation]    This Keyword Navigates To An Asset / VOD Detailpage 
    ...    From CMM Of VOD.
    ...    Pre requisites - Movies and Series Should be highlighted in Main Menu
    On Demand is focused
    ${cmm_tiles}    I retrieve value for key 'children' in element 'id:contextualMainMenu-navigationContainer-MOVIES_SERIES_elements_container'
    ${no_tiles}    Get length    ${cmm_tiles}
    ${random_tile}    Evaluate    random.randrange(0,$no_tiles)    modules=random
    I press    DOWN
    Run Keyword If    ${random_tile} != ${0}    I press RIGHT ${random_tile} times
    I Press    INFO
    VOD Details Page is shown

Validate Recently Added From Contextual Main Menu Of On Demand    #USED
    [Documentation]  This keyword verifies recently added section of contextual main menu of on demand
    ...    Precondition: Main menu is opened
    Variable Should Exist    ${RECENTLY_ADDED_ITEMS}    Details of Recently Added Section Not Saved
    Validate A Given Section From Contextual Main Menu Of On Demand    Recently added    ${RECENTLY_ADDED_ITEMS}

Validate Recommended For You From Contextual Main Menu Of On Demand    #USED
    [Documentation]  This keyword verifies recommended for you section of contextual main menu of on demand
    ...    Precondition: Main menu is opened
    Variable Should Exist    ${RECOMMENDED_ITEMS}    Details of Recently Added Section Not Saved
    Validate A Given Section From Contextual Main Menu Of On Demand    DIC_CONTEXTUAL_MAIN_MENU_RECOMMENDED    ${RECOMMENDED_ITEMS}

Validate A Given Section From Contextual Main Menu Of On Demand    #USED
    [Documentation]  This keyword verifies given section of contextual main menu of on demand
    ...    Argument section_key is the title when section is focused and section_asset_details is details of section from backend.
    ...    Precondition: Main menu is opened
    [Arguments]    ${section_key}    ${section_asset_details}
    ${asset_list}    Create List
    I Press    DOWN
    ${focused_node}    Get Ui Focused Elements
    ${tiles}    Extract Value For Key    ${focused_node}    id:contextualMainMenu-navigationContainer-MOVIES_SERIES    data
    ${length}    Get Length    ${tiles}
    ${index}    Set Variable    ${0}
    ${ui_json}    Get Ui Json
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${is_recent}    Run Keyword And Return Status    Should Be Equal As Strings    ${tiles[${i}]['title']}    ${section_key}
    \    Continue For Loop If    ${is_recent}==${False}
    \    ${search_param_title}    Catenate    SEPARATOR=
    ...    id:programme-title-contextualMainMenu-navigationContainer-MOVIES_SERIES_element_    ${i}
    \    ${search_param_poster}    Catenate    SEPARATOR=
    ...    id:poster-contextualMainMenu-navigationContainer-MOVIES_SERIES_element_    ${i}
    \    ${title}    Extract Value For Key    ${ui_json}    ${search_param_title}    textValue    ${False}
    \    Should Be Equal As Strings    ${section_asset_details[${index}]['title']}    ${title}    Asset title could not be verified
    \    ${is_adult}    Extract Value For Key    ${section_asset_details[${index}]}    ${EMPTY}    isAdult
    \    Should Be Equal As Strings    ${is_adult}    False    Age rated VOD Assets displayed in CMM for On demand
    \    ${poster_details}    Extract Value For Key    ${ui_json}    ${search_param_poster}    background    ${False}
    \    ${image_url}    Extract Value For Key    ${poster_details}    ${EMPTY}    url    ${False}
    \    Validate Detailpage Poster    ${image_url}
    \    Append To List    ${asset_list}    ${title}
    \    ${index}     Evaluate   ${index}+${1}
    List Should Not Contain Duplicates    ${asset_list}    Duplicate assets in On Demand CMM

I focus Search Saved
    [Documentation]    Keyword to focus Search on Main menu
    Move Focus to Section for Saved Search    SEARCH    iconKeys

Home is shown    #USED
    [Documentation]    Keyword to verify Main Menu is shown
#    ${action_found}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    0 s    I expect page contains 'id:shared-CollectionsBrowser'
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    id:contextualMainMenu|personalhome-sectionNavigation    ${EMPTY}    ${true}
    Should Be True    ${result}    CMM Sections are not loaded
#    ${action_found}    Is In Json    ${json_object}    ${EMPTY}    id:shared-CollectionsBrowser   ${EMPTY}    ${true}
#    Should Be True    ${action_found}
    #CMM content is loaded
    ${result}    Is In Json    ${json_object}    ${EMPTY}    id:contextualMainMenu-navigationContainer.*|personalhome-sectionNavigation-.*    ${EMPTY}    ${True}
    Should Be True    ${result}    CMM content is not loaded

    ${action_found}    Is In Json    ${json_object}    ${EMPTY}    id:shared-CollectionsBrowser   ${EMPTY}    ${true}
    Should Be True    ${action_found}

    ${action_found}    Is In Json    ${json_object}    ${EMPTY}    id:shared-CollectionsBrowser_collection_[\\d]+_elements_container   ${EMPTY}    ${true}
    Should Be True    ${action_found}  CMM containers not loaded

    ${action_found}    Is In Json    ${json_object}    ${EMPTY}    id:shared-CollectionsBrowser_collection_[\\d]+_tile_[\\d]+_contentTile   ${EMPTY}    ${true}
    Should Be True    ${action_found}  CMM containers content not loaded

    ${action_found}    Is In Json    ${json_object}    ${EMPTY}    id:PersonalHome.View   ${EMPTY}    ${true}
    Should Be True    ${action_found}  CMM view not loaded
