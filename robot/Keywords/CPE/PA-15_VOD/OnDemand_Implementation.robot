*** Settings ***
Documentation     On Demand Implementation keywords
Resource          ../Common/Common.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot
Resource          ../PA-15_VOD/VodDetailsPage_Keywords.robot
Resource          ../CommonPages/DeepLink_Keywords.robot
Resource          ../CommonPages/SectionNavigation_Keywords.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-15_VOD/Saved_Keywords.robot

*** Variables ***
&{vod_section_types_dictionary}    New MyPrime=Basic    Action=Grid    New Seasons=Basic    Pre-school movies=Grid    Just in from the Cinema=Grid    Movie Highlights=Basic
&{providers_image_ids_dictionary}    HBO=NodeImages_4bd0f257_fcd0_4a2d_9509_91bbcc76bd9d    National Geographic=NodeImages_04909413_21a8_421f_8800_387769af148f    SBS6=NodeImages_4a73aa01_bfae_4f41_887f_03e1952b1b6d
&{providers_ids_dictionary}    HBO=crid:~~2F~~2Fschange.com~~2F1f931b94-85ae-42c9-ab86-38f7cc683dba    National Geographic=crid:~~2F~~2Fschange.com~~2F6eb120aa-2009-4472-a74a-acbcabe08509    SBS6=crid:~~2F~~2Fschange.com~~2Fef811996-1232-4cfa-a7d9-c7ad814eb1b3
&{providers_crids_dictionary}    HBO=crid:~~2F~~2Fschange.com~~2F2926fe19-461e-424e-b299-85e46cf9b30e
&{RENT_IDS_DICTIONARY}    nl=a la carte    en=rent
@{REAL_CONTENT_ASSETS}    crid:~~2F~~2Fe2e-si.lgi.com~~2F10138-iron-man-2    crid:~~2F~~2Fe2e-si.lgi.com~~2F483104-a-christmas-prince
@{REAL_CONTENT_ASSETS_RENTED}    crid:~~2F~~2Fe2e-si.lgi.com~~2F297802-aquaman    crid:~~2F~~2Fe2e-si.lgi.com~~2F99861-avengers-age-of-ultron-interlaced    crid:~~2F~~2Fe2e-si.lgi.com~~2F10946-earth
@{EPISODE_ONDEMAND_VARIABLES_LIST}    EzyListepisodeList    OK
@{SEASON_ONDEMAND_VARIABLES_LIST}    seasonList    LEFT
${ON_DEMAND_RENT_SECTION_ID}    crid:~~2F~~2Fschange.com~~2Faa9540d0-90bd-4bfb-b6f3-d64a8c2f467e
${ON_DEMAND_PROVIDERS_SECTION_ID}    crid:~~2F~~2Fschange.com~~2Fa31b3fce-3501-4e34-818a-64aaaaf28e06
${DISCOVER_CONTINUE_WATCHING_COLLECTION_ID}    crid:~~2F~~2Fschange.com~~2F76dc6222-67e5-4dd3-9ab0-5532a98a12f6
${SAVED_CONTINUE_WATCHING_SECTION_ID}    saved/continue-watching
${DP_RENT_SECTION_ID}    RENT
${SECOND_LEVEL_GRID}    ${False}
${SECOND_LEVEL_COLLECTION}    ${False}
${SECOND_LEVEL_EDITORIAL_GRID}    ${False}
${SVOD_SUBSCRIBE_BOXSET_SERIES_TILE}    Arrow
${TVOD_RENT_BOXSET_SERIES_TILE}    12 Monkeys
${MULTIPLE_LANGUAGES_VOD_MOVIE}    Frozen AC3
${WEBFEED_TILE}    Frozen
${WEBFEED_MOVIES_TILE}    Pirates of the Caribbean: Dead Men Tell No Tales
${TVOD_NO_TRAILER}    Logan
@{SHORT_DURATION_VOD_ASSETS}    Teachers
${MULTIOFFERS_TVOD_ASSET}    Spider-Man: Homecoming
${FULL_LENGTH_SERIES_TVOD_ASSET}    Black Sails
${BOXSET_SERIES_TILE}    12 Monkeys
${TVOD_RENT_TV_SHOW_SERIES_TILE}    CBS News Sunday Morning
${SVOD_SUBSCRIBE_TV_SHOW_SERIES_TILE}    Kim Possible
${VOD_HD_SD_ASSET}    Spider-Man: Homecoming
&{VOD_SORT_DICTIONARY}    DIC_SORT_DATE=broadcastDate    DIC_SORT_POPULARITY=popularity    DIC_SORT_A-Z=name    DIC_SORT_YEAR_OF_RELEASE=prodYear
${VOD_ASSET_MIN_DURATION}    600
${VOD_ASSET_MAX_DURATION}    10000

*** Keywords ***
Generate OnDemand category dictionary    #USED
    [Documentation]    Lookup Ondemand menu and populate the visible tab elements into a dictionary
    ${sections}    ${number_of_sections}    Get Current Sections
    Should Not Be Empty    ${sections}    No child elements detected for ondemand menu json container
    &{dict}    Create Dictionary
    : FOR    ${section}    IN    @{sections}
    \    ${element_value}    convert to lowercase    ${section['title']}
    \    Set To Dictionary    ${dict}    ${element_value}    ${section['id']}
    Set Suite Variable    ${VOD_SECTION_IDS_DICTIONARY}    ${dict}

Retrieve VOD Root Category Structure From Backend    #USED
    [Documentation]    This keyword retrieves VOD Category Root Structure From Backend
    ${structure_json}    Get Vod Full Vod Structure
    ${dict}    Create Dictionary
    :FOR    ${screen}    IN    @{structure_json['screens']}
    \    ${section_title}    Convert To Lowercase    ${screen['title']}
    \    Set To Dictionary    ${dict}    ${section_title}    ${screen['id']}
    Set Suite Variable    ${VOD_SECTIONS_DICTIONARY}    ${dict}

Get Asset Crid From Vodscreen Response Of An Asset    #USED
    [Documentation]    This keyword retrieves asset crid from /vodscreen response of an asset.
    ...    it returns crid from gridlink field if the field is present, returns crid from id field otherwise
    [Arguments]    ${asset_details}
    ${gridlink_field}    Extract Value For Key    ${asset_details}    ${EMPTY}    gridLink
    ${gridlink_crid}    Run Keyword If    '''${gridlink_field}'''!="${None}"    Extract Value For Key    ${gridlink_field}    ${EMPTY}    id
    ${crid_id}    Set Variable If    '''${gridlink_crid}'''!="${None}"    ${gridlink_crid}    ${asset_details['id']}
    [Return]    ${crid_id}

Get On Demand Section Id
    [Arguments]    ${section}
    [Documentation]    Retrieve an On Demand section name in dictionary and return its section id
    variable should exist    ${VOD_SECTION_IDS_DICTIONARY}    VOD section dictionary was not created. VOD_SECTION_IDS_DICTIONARY does not exist.
    ${lowercase_section}    convert to lowercase    ${section}
    ${section_id}    Set Variable    &{VOD_SECTION_IDS_DICTIONARY}[${lowercase_section}]
    [Return]    ${section_id}

Find SVOD Tile in Collection
    [Documentation]    This keyword is looking for a SVOD tile in Collection by focusing them one by one and checking
    ...    their properties via a call to the VOD service
    ${nodes}    Get Ui Focused Elements
    ${collection_assets_data}    Extract Value For Key    ${nodes}    id:^(Basic|Grid)Collection_\\d+    items    ${True}
    ${number_of_assets}    Get Length    ${collection_assets_data}
    : FOR    ${_}    IN RANGE    ${number_of_assets}
    \    ${is_svod}    Focused Tile is a Movie SVOD
    \    Exit For Loop If    '${is_svod}' == 'True'
    \    Press Key    RIGHT
    [Return]    ${is_svod}

Focused Tile is a Movie SVOD
    [Documentation]    Checks if the focused tile is a Movie SVOD via the VOD service
    ${nodes}    Get Ui Focused Elements
    ${number_of_nodes}    Get Length    ${nodes}
    ${tile}    Set Variable    ${nodes[${number_of_nodes - 1}]}
    ${crid}    Set Variable    ${tile['data']['id']}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${info}    get asset by crid    ${LAB_CONF}    ${crid}    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${CUSTOMER_ID}
    ...    ${CPE_ID}
    ${is_serie}    Is In Json    ${info}    ${EMPTY}    seriesId:.*    ${EMPTY}    ${True}
    ${subscription_id}    Extract Value For Key    ${info}    type:Subscription    id
    ${is_ok}    Evaluate    (${is_serie} == ${False}) and ('${subscription_id}' != '${None}')
    [Return]    ${is_ok}

VOD screen content has loaded
    [Arguments]    ${vod_category}=${EMPTY}
    [Documentation]    This keyword asserts the VOD screen content for the ${vod_category} category
    ...    has loaded and returns it.
    ${vod_category}    Convert To Lowercase    ${vod_category}
    ${container_id}    Set Variable If    '${vod_category}' == 'providers'    shared-CollectionsBrowser    ^.*CollectionsBrowser
    ${container}    I retrieve value for key 'children' in element 'id:${container_id}' using regular expressions
    Should Be True    ${container} != None    Collection container is None
    Should Not Be Empty    ${container}    Collection container is empty
    [Return]    ${container}

I prevent vod player progress bar from disappearing
    [Documentation]    This keyword prevents the progress bar from disappearing in the VOD player.
    ${json_object}    Get Ui Json
    ${is_player_present}    Is In Json    ${json_object}    ${EMPTY}    id:playerControlsPanel-Player
    Run Keyword If    '${is_player_present}' != 'True'    I Press    OK
    ...    ELSE    LOG    "Progress bar is shown"

Watchlist grid screen is shown implementation
    [Documentation]    This keyword verifies if the Watchlist grid screen is shown - with assets or empty.
    ...    Precondition: Watchlist screen should be open
    ${status_empty_screen}    Run Keyword And Return Status    Watchlist screen is empty
    ${watchlist_screen_not_empty}    Run Keyword And Return Status    Watchlist collection is visible
    ${screen_visible}    Evaluate    True if ${status_empty_screen} or ${watchlist_screen_not_empty} else False
    Should Be True    ${screen_visible}

Recordings collection screen is shown implementation
    [Documentation]    This keyword verifies if the Recordings collection screen is shown - with assets or empty,
    ...    Precondition: Recordings screen should be open.
    ${json_object}    Get Ui Json
    ${is_not_empty}    Recordings collection screen is not empty validation    ${json_object}
    ${is_empty}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_RECORDINGS_EMPTY_TITLE
    ${has_tile_collection}    Is In Json    ${json_object}    ${EMPTY}    id:^.*CollectionsBrowser_collection_\\d+    ${EMPTY}    ${True}
    ${is_displayed}    Evaluate    True if ${is_not_empty} or ${is_empty} or ${has_tile_collection} else False
    Should Be True    ${is_displayed}

VOD tiles are shown implementation
    [Documentation]    This keyword verifies VOD tiles are shown in the UI.
    ${json_object}    Get Ui Json
    ${tile_collection_present}    Is In Json    ${json_object}    ${EMPTY}    id:^.*CollectionsBrowser_collection_\\d+    ${EMPTY}    ${True}
    ${grid_collection_present}    Is In Json    ${json_object}    ${EMPTY}    id:CollectionContainer_grid_\\d+    ${EMPTY}    ${True}
    ${basic_collection_present}    Is In Json    ${json_object}    ${EMPTY}    id:BasicCollection_\\d_tile_\\d+    ${EMPTY}    ${True}
    ${provider_tile_present}    Is In Json    ${json_object}    ${EMPTY}    id:providerGridTile-\\d+    ${EMPTY}    ${True}
    ${vod_tiles_shown}    Evaluate    True if ${tile_collection_present} or ${grid_collection_present} or ${basic_collection_present} or ${provider_tile_present} else False
    Should Be True    ${vod_tiles_shown}

Rented grid screen is shown implementation
    [Documentation]    This keyword verifies if the Rented grid screen is shown,
    ...    Precondition: Rented screen in Saved should be open.
    ${json_object}    Get Ui Json
    ${is_not_empty}    Is In Json    ${json_object}    ${EMPTY}    id:GridCollection_\\d+_tile_\\d+    ${EMPTY}    ${True}
    ${is_empty}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_RENTED_EMPTY_TITLE
    ${is_displayed}    Evaluate    True if ${is_not_empty} or ${is_empty} else False
    Should Be True    ${is_displayed}

Recordings collection screen is not empty validation
    [Arguments]    ${json_object}
    [Documentation]    This keyword verifies if the Recordings collection screen given in ${json_object}
    ...    is shown properly when not empty, and returns True if not empty.
    ...    Precondition: Recordings screen is already opened
    ${is_not_empty}    Is In Json    ${json_object}    ${EMPTY}    id:^.*CollectionsBrowser_collection_\\d+_tile_\\d+_primaryTitle    ${EMPTY}    ${True}
    Run Keyword If    ${is_not_empty} == True    Run Keywords    I expect page contains 'textKey:DIC_RECORDING_LABEL_RECORDED'
    ...    AND    I expect page contains 'textKey:DIC_ENTRY_TILE_PLANNED_REC'
    [Return]    ${is_not_empty}

Watchlist collection is visible
    [Documentation]    This keyword verifies if the Watchlist collection is visible in the UI,
    ...    Precondition: Watchlist screen should be open.
    ${json_object}    Get Ui Json
    ${is_collection_present}    Is In Json    ${json_object}    ${EMPTY}    id:.*CollectionsBrowser    ${EMPTY}    ${True}
    Should Be True    ${is_collection_present}    msg=Watchlist collection is not visible

Series title is shown on Saved view implementation
    [Documentation]    This keyword asserts the Series title in the ${TILE_TITLE} variable is shown on the Saved screen.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{is_collection_present}    get regexp matches    ${json_string}    .*>(${TILE_TITLE})<\\/font>.*    1
    Should be equal    @{is_collection_present}[0]    ${TILE_TITLE}    msg=Series title is not shown on Saved view

Is provider screen present
    [Documentation]    This keyword verifies if provider tiles are present in the current screen and returns True if so.
    ${json_object}    Get Ui Json
    ${provider_tile_present}    Is In Json    ${json_object}    ${EMPTY}    id:providerTile-\\d+    ${EMPTY}    ${True}
    [Return]    ${provider_tile_present}

Is collection screen present
    [Documentation]    This keyword verifies if collection tiles are present
    ...    in the current screen and returns True if so.
    ${json_object}    Get Ui Json
    ${basic_collection_present}    Is In Json    ${json_object}    ${EMPTY}    id:CollectionContainer_BasicCollection_.*    ${EMPTY}    ${True}
    [Return]    ${basic_collection_present}

Get asset info
    [Arguments]    ${asset_crid}
    [Documentation]    This keyword gets an asset metadata by providing its crid and returns its info.
    ${cpe_profile_id}    get traxis profile id    ${LAB_CONF}
    ${asset_info}    get asset by crid    ${LAB_CONF}    ${asset_crid}    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${CUSTOMER_ID}
    ...    ${CPE_ID}
    [Return]    ${asset_info}

Get TVOD non-entitled asset title
    [Arguments]    ${vod_section}    ${multiple_quality}=Any
    [Documentation]    This keyword searches and returns the title of a TVOD non-entitled single asset
    ...    in the given ${vod_section}. If ${multiple_quality} is 'True', fetches only the single VOD assets having multiple instances to rent
    ...    default value is 'Any' by which the keyword returns vod assets with or without multiple instances.
    ${number_assets}    Get Length    ${vod_section}
    ${asset_title}    Set Variable    ${EMPTY}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${multiple_quality}    Set Variable If    "${multiple_quality}"=="${True}"    ${True}    ${False}
    ${unentitled_assets}    Run Keyword If    ${multiple_quality}    Create Dictionary    ELSE    Create List
    ${all_asset_data}    Create List
    : FOR    ${i}    IN RANGE    ${0}    ${number_assets}
    \    ${crid_id}    Get Asset Crid From Vodscreen Response Of An Asset    ${vod_section[${i}]}
    \    ${asset_details}    get asset by crid    ${LAB_CONF}    ${crid_id}    ${COUNTRY}    ${OSD_Language}    ${cpe_profile_id}
    \    ...    ${CUSTOMER_ID}
    \    ${is_4K}    Run Keyword If    not ${multiple_quality}
    ...    Check Whether VOD Asset Has Multiple Instances From Asset Details    ${asset_details}    ${True}
    \    Continue For Loop If    not ${multiple_quality} and ${is_4K}
    \    ${duration}    Extract Value For Key    ${asset_details}    ${EMPTY}    duration
    \    ${valid}    Set Variable If    ${duration}>${0}    ${True}    ${False}
    \    Continue For Loop If    ${valid}==${False}
    \    ${check_condition}    Run Keyword If    ${multiple_quality}
    ...    Check Whether VOD Asset Is Unentitled And Has Multiple Instances From Asset Details    ${asset_details}
    ...    ELSE    Check Whether VOD Asset Is Unentitled From Asset Details    ${asset_details}
    \    Continue For Loop If    ${check_condition}==${False}
    \    Run Keyword If    ${multiple_quality}==${False}    Append To List    ${unentitled_assets}    ${vod_section[${i}]['title']}
    \    Continue For Loop If    ${multiple_quality}==${True}
    #\    ${instance_list}    Extract Value For Key    ${asset_details}    ${EMPTY}
    #...    instances    ${False}
    \    Append to List    ${all_asset_data}    ${asset_details}
    #\    Set To Dictionary    ${unentitled_assets}    ${vod_section[${i}]['title']}    ${instance_list}
    Set Suite Variable    ${TVOD_UNENTITLED_ASSETS}   ${all_asset_data}
    [Return]    ${unentitled_assets}

Check Whether VOD Asset Is Unentitled From Asset Details    #USED
    [Documentation]    This keyword checks whether given asset is unentitled. Asset details are to be provided.
    ...    Returns true if asset is unentitled and false otherwise.
    [Arguments]    ${asset_details}
    ${is_tvod}    Is In Json    ${asset_details}    ${EMPTY}    type:Transaction    ${EMPTY}    ${True}
    ${is_tvodentitledEnd}    Is In Json    ${asset_details}    ${EMPTY}    tvodEntitlementEnd:    ${EMPTY}    ${True}
    ${is_subscribed}    Is In Json    ${asset_details}    ${EMPTY}    type:Subscription    ${EMPTY}    ${True}
    Return From Keyword If    ${is_subscribed}    ${False}
    Should Not Be Empty    ${asset_details['title']}
    ${is_unentitled}    Set Variable If    ${is_tvod}==${False}    ${False}    ${is_tvodentitledEnd}    ${False}    ${True}
    [Return]    ${is_unentitled}

Check Whether VOD Asset Has Multiple Instances From Asset Details    #USED
    [Documentation]    This keyword checks whether a given unentitled asset has multiple instances to rent from
    ...    or not. Returns true if so, false otherwise
    [Arguments]    ${asset_details}    ${exclude_4K_assets}=${False}
    ${instance_list}    Extract Value For Key    ${asset_details}    ${EMPTY}    instances    ${False}
    ${instances}    Get Length    ${instance_list}
    ${is_multiple_quality}    Set Variable If    ${instances}>${1}    ${True}    ${False}
    Return From Keyword If    not ${exclude_4K_assets}    ${is_multiple_quality}
    :FOR    ${i}    IN RANGE    0    ${instances}
    \    ${resolution}    Extract Value For Key    ${instance_list[${i}]}    ${EMPTY}    resolution    ${False}
    \    ${is_4K}    Set Variable If    "${resolution}"=="4K"    ${True}    ${False}
    \    Exit For Loop If    ${is_4K}
    [Return]    ${is_4K}

Check Whether VOD Asset Is Unentitled And Has Multiple Instances From Asset Details    #USED
    [Documentation]    This keyword checks whether a VOD asset whose details is given is unentitled. If so, checks
    ...    whether it has multiple instances to rent from
    [Arguments]    ${asset_details}
    ${is_unentitled}    Check Whether VOD Asset Is Unentitled From Asset Details    ${asset_details}
    Return From Keyword If    ${is_unentitled}==${False}    ${is_unentitled}
    ${is_multiple_quality}   Check Whether VOD Asset Has Multiple Instances From Asset Details    ${asset_details}
    [Return]    ${is_multiple_quality}

I focus Grid entry tile in '${section}' in '${collection}'
    [Documentation]    This keyword focuses the Grid entry tile for '${collection}' collection
    ...    inside the VOD section '${section}' in the VOD screen.
    ...    Precondition: VOD screen should be open.
    I open '${section}'
    I Press    OK
    Skip A-Spot collection
    Move Focus to Collection named    ${collection}

Verify if vod tiles are shown by scrolling down
    [Documentation]    This keyword asserts VOD tiles are shown by scrolling down.
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 times    1 s    VOD tiles are shown implementation
    run keyword if    ${status} == ${False}    I Press    DOWN
    should be true    ${status}    vod tiles not shown

Rent is focused
    [Documentation]    This keyword asserts the 'Rent' section is focused.
    Section is Focused    ${ON_DEMAND_RENT_SECTION_ID}

I focus record button
    [Documentation]    This keyword focuses the record button in linear details page and verifies is focused.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_RECORD'
    Move Focus to Section    DIC_ACTIONS_RECORD    textKey

I set budget limit to
    [Arguments]    ${budget}
    [Documentation]    This keyword sets the budget limit of VOD purchase via itfaker to the given ${budget}.
    ${resp}    set budget    ${budget}    ${LAB_TYPE}    ${CPE_ID}
    ${resp_code}    evaluate    json.loads('''${resp[0]}''')    json
    should be equal    '${resp_code["status"]}'    '200'
    should be equal    '${resp_code["message"]}'    'OK'

I enter a valid pin for VOD Rent    #USED
    [Documentation]    This keyword verifies a VOD asset purchase pin entry popup is shown, and enters a correct pin.
    ...    Precondition: Pin entry popup for VOD should be displayed.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Pin entry for VOD asset purchase is shown
    Type a valid pin

Pin entry for VOD asset purchase is shown    #USED
    [Documentation]    This keyword verifies if the asset purchase pin entry popup is displayed.
    wait until keyword succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'

I focus the 'Continue watching' action
    [Documentation]    This keyword focuses the 'Continue Watching' action and verifies it is focused.
    Move Focus to Section    DIC_ACTIONS_CONTINUE_WATCHING    textKey

I try to rent a VOD movie
    [Documentation]    This keyword attempts to rent a movie from the VOD section
    ...    of the On Demand screen.
    Get Root Id From Purchase Service
    I open On Demand through Main Menu
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    :FOR    ${section_name}    IN    @{VOD_SECTION_IDS_DICTIONARY.keys()}
    \    Log    ${section_name}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    Continue For Loop If  '''${section_name}''' == '''series'''
    \    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    \    ...    ${CUSTOMER_ID}    all
    \    ${unentitled_assets}    Get TVOD non-entitled asset title    ${movies_details}
    \    ${assets_found}    Run Keyword And Return Status    Should Not Be Empty    ${unentitled_assets}
    \    Exit For Loop If    ${assets_found}
    Should Not Be Empty    ${unentitled_assets}    Unentitled TVOD assets not found
    ${random_tvod_title}    Get Random Element From Array    ${unentitled_assets}
    Set Test Variable    ${RENTED_MOVIE_TITLE}    ${random_tvod_title}
    Set Test Variable    ${NON_ADULT_RENTED_TILE_TITLE}    ${random_tvod_title}
    I open '${section_name}'
    I press    DOWN
    I focus '${RENTED_MOVIE_TITLE}' tile
    I open VOD Detail Page
    I rent the selected asset

I focus Show all in VOD
    [Documentation]    This keyword focuses the 'Show all' tile in any VOD section of the On Demand screen.
    ...    Precondition: VOD screen should be open.
    Move Focus to Grid Collection
    Move Focus to Grid Link

I open the Details Page of a series asset with episodes in VOD
    [Documentation]    This keyword focuses a series tile from 'Show all' tile of the Series section,
    ...    finds an asset that has episodes listed saving the title in the ${TILE_TITLE} variable, keeping the
    ...    Details Page open.
    I open a grid screen
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_gridCounter' contains 'textValue:^.+$' using regular expressions
    ${max_assets}    retrieve asset count in open vod grid
    : FOR    ${i}    IN RANGE    ${1}    ${max_assets}
    \    ${status}    run keyword and return status    I open VOD Detail Page
    \    ${title}    I retrieve value for key 'textValue' in element 'id:title'
    \    ${status}    run keyword and return status    'Episodes' action is shown
    \    Run Keyword If    ${status}    Run Keywords    set test variable    ${TILE_TITLE}    ${title}
    \    ...    AND    Exit For Loop
    \    I Press    INFO
    \    I press    RIGHT
    run keyword if    '${TILE_TITLE}'=='${EMPTY}'    Fail    No valid series event found

VOD series tile is focused
    [Documentation]    This keyword verifies if the VOD series tile is focused.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:.*CollectionsBrowser_collection_\\\\d+_tile_\\\\d+' using regular expressions

Editorial grid screen is shown
    [Documentation]    Verifies if the page being shown is an editorial grid screen
    ...    For the new grid there will be a field to check the grid tipe: gridLayout
    VOD Grid Screen is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:editorialGridBG-background-layer-1' contains 'image:.*png.*' using regular expressions

I open a second level collections screen
    [Documentation]    This keyword opens the 'HBO' collections screen from the 'Providers' collections screen section
    ...    from the On Demand screen, verifies the collections screen is shown
    ...    saving the result in the ${SECOND_LEVEL_COLLECTION} variable.
    I open 'Providers'
    I press    DOWN
    I focus 'HBO' in providers section
    I press    OK
    Collections screen is shown
    Set Test Variable    ${SECOND_LEVEL_COLLECTION}    ${True}

I focus '${provider_name}' in providers section
    [Documentation]    This keyword focuses the ${provider_name} tile in the providers section
    ...    Precondition: The id of the provider tile image should be in {providers_image_ids_dictionary}
    ${tiles_container_data}    I retrieve value for key 'data' in focused element 'id:.*CollectionsBrowser' using regular expressions
    ${providers_tiles_count}    Get Length    ${tiles_container_data}
    : FOR    ${i}    IN RANGE    ${providers_tiles_count}
    \    ${tile_data}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I retrieve value for key 'data' in focused element 'id:.*CollectionsBrowser_collection_\\\\d+_tile_\\\\d+.*' using regular expressions
    \    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:SectionNavigationListItem-.+' using regular expressions
    \    ${is_focused}    Evaluate    '${tile_data['id']}' == '&{providers_ids_dictionary}[${provider_name}]'
    \    Exit For Loop If    ${is_focused} == True
    \    I press    RIGHT
    Should Be True    ${is_focused}    Could not focus the '${provider_name}' provider Tile

Get title to focus in provider
    [Arguments]    ${provider_name}
    [Documentation]    This keyword retrieves first title of tile from providers screen for the given ${provider_name}
    ${crid}    Set Variable    &{providers_crids_dictionary}[${provider_name}]
    @{content}    get providers category titles    ${crid}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${item}    get asset by crid    ${LAB_CONF}    @{content}[0]    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${CUSTOMER_ID}
    ...    ${CPE_ID}
    [Return]    ${item['title']}

I focus a poster tile
    [Documentation]    This keyword checks which screen is shown and focuses a poster tile in that screen.
    Skip A-Spot collection
    Skip promotional and editorial tiles
    ${is_provider_screen}    Is provider screen present
    ${is_collection_screen}    Is collection screen present
    Run Keyword If    ${is_provider_screen}    I focus a poster tile in providers
    ...    ELSE IF    ${is_collection_screen}    I focus a poster tile in collection
    Poster tile is focused

I focus a poster tile in providers
    [Documentation]    This keyword focuses HBO's poster tile in providers
    ${title}    Get title to focus in provider    HBO
    I focus '${title}' tile

Focus poster tile in first level collection screen
    [Documentation]    This keyword focuses a poster tile in first level collection screen,
    ...    saving the asset's title in the ${TILE_TITLE} variable.
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    &{movie_details}    Get Content    ${LAB_CONF}    Movies    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    Should Not Be Empty    &{movie_details}[title]
    VOD tiles are shown
    set test variable    ${TILE_TITLE}    &{movie_details}[title]
    I focus '${TILE_TITLE}' tile

Focus poster tile in second level collection screen
    [Documentation]    This keyword focuses a poster tile in the 'HBO' collection screen.
    &{asset_details}    Get Content    ${LAB_CONF}    Providers    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    single
    ...    collection    HBO
    should not be empty    &{asset_details}[title]    Failed to get poster tile in the 'HBO' collection screen
    I focus '&{asset_details}[title]' tile

I focus a poster tile in collection
    [Documentation]    This keyword focuses a poster tile in a first or second level collection screen.
    Run Keyword If    ${SECOND_LEVEL_COLLECTION}    Focus poster tile in second level collection screen
    ...    ELSE    Focus poster tile in first level collection screen

Collections screen is shown
    [Documentation]    This keyword verifies if the collections screen is shown.
    ${aspot_present}    Is A-Spot present
    ${basic_collection_present}    Run Keyword And Return Status    wait until keyword succeeds    10 times    1 sec    I expect page contains 'id:CollectionContainer_BasicCollection_.*' using regular expressions
    Should Be True    ${aspot_present} or ${basic_collection_present}    Collections screen or A-Spot is not there

Second level collections screen with section navigation is shown
    [Documentation]    This keyword verifies if the second level collections screen
    ...    saved in the ${EDITORIAL_GRID_SCREEN_TITLE} variable is shown.
    wait until keyword succeeds    10 times    1 sec    I expect page contains 'id:SectionNavigationScrollContainershared-SectionNavigation'
    wait until keyword succeeds    10 times    1 sec    I expect page element 'id:mastheadSecondaryTitle' contains 'textValue:${EDITORIAL_GRID_SCREEN_TITLE}' using regular expressions

I open non-entitled asset in current grid
    [Documentation]    This keyword searches and focuses a non entitled (not rented)
    ...    and unwatched asset from the currently opened grid.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_gridCounter' contains 'textValue:^.+$' using regular expressions
    ${max_assets}    retrieve asset count in open vod grid
    : FOR    ${i}    IN RANGE    ${1}    ${max_assets}
    \    wait until keyword succeeds    3 times    100 ms    I open VOD Detail Page
    \    ${json_object}    Get Ui Json
    \    ${rent_for_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT
    \    ${rent_from_presence}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ACTIONS_RENT_FROM
    \    ${rental_action_to_use}    set variable if    ${rent_for_presence}    DIC_ACTIONS_RENT    ${rent_from_presence}    DIC_ACTIONS_RENT_FROM
    \    ...    ${EMPTY}
    \    return from keyword if    ${rent_for_presence} or ${rent_from_presence}    ${rental_action_to_use}
    \    I Press    INFO
    \    wait until keyword succeeds    20 times    100 ms    VOD Detail Page is not shown
    \    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_gridCounter' contains 'textValue:^.+$' using regular expressions
    \    I press    RIGHT
    Fail    Non-entitled asset in current grid not found

Purchase flow continues
    [Documentation]    This keyword verifies the pin entry popup disappears and the play options are shown for the asset.
    'WATCH' or 'PLAY FROM START' actions are shown

Check if 'Rent for' option is focused
    [Documentation]    This keyword verifies if the 'Rent for' option is focused when
    ...    invoked via Contextual Key Menu on a Movie Tile.
    Section is Focused    DIC_ACTIONS_RENT    textKey

I rent the focused asset
    [Documentation]    This keyword rents an asset from the currently opened Details Page if
    ...    it has an unknown expiry time, or the expiry time is lower than 15 minutes, otherwise the keyword fails.
    ...    Precondition: A VOD Details Page screen should be open.
    I select valid rent option
    ${status}    run keyword and return status    wait until keyword succeeds    5 times    100 ms    I expect page contains 'id:interactiveModalPopup'
    should be true    ${status}    Multiple rental format options not available
    ${status}    ${wait_duration}    run keyword and ignore error    get duration from focused rental option
    # Some events dont present duration of rental in the popup, so need to be handled as well
    run keyword if    '${status}'=='PASS'    run keywords    should be true    ${wait_duration}<=${900}    Asset expiry time exceeds 15 mins
    ...    AND    set test variable    ${EXPIRY_DURATION}    ${wait_duration}
    ${json_object}    Get Ui Json
    I press    OK
    wait until keyword succeeds    5s    100ms    Assert json changed    ${json_object}
    Pin Entry popup is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'
    I enter a valid pin ensuring the rental process succeeds
    wait until keyword succeeds    20s    1s    Player is in PLAY mode

Rented VOD asset is available
    [Documentation]    This keyword focuses and open the Details Page of non adult VOD rented asset
    ...    saved in the ${REAL_CONTENT_ASSETS} variable and rents it, saving the title in the ${TILE_TITLE} variable.
    I make sure budget limit is set to    ${BUDGET_HIGH}
    ${current_country_code}    Read current country code
    ${current_country_code_uppercase}    convert to uppercase    ${current_country_code}
    ${length}    Get Length    ${REAL_CONTENT_ASSETS_RENTED}
    I open rental category in vod
    I press    DOWN
    I navigate to all genres vod screen
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    : FOR    ${index}    IN RANGE    ${0}    ${length}
    \    ${crid}    set variable    ${REAL_CONTENT_ASSETS_RENTED[${index}]}
    \    ${item}    get asset by crid    ${LAB_CONF}    ${crid}    ${current_country_code_uppercase}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    \    ...    ${CUSTOMER_ID}    ${CPE_ID}
    \    ${asset_is_focused}    run keyword and return status    I focus '${item['title']}' tile
    \    run keyword if    ${asset_is_focused}==False    run keywords    Focus Back to top
    \    ...    AND    I press    OK
    \    ...    AND    I open rental category in vod
    \    ...    AND    I press    DOWN
    \    ...    AND    I open show all tile in vod
    \    ...    AND    continue for loop
    \    I open VOD Detail Page
    \    set test variable    ${TILE_TITLE}    ${item['title']}
    \    I rent the focused asset
    \    exit for loop

I open rental category in vod
    [Documentation]    This keyword identifies the rental category id for the respective language, and attempts to
    ...    open the VOD category in the On Demand screen
    ...    Precondition: VOD screen should be open.
    ${rent_category_id}    retrieve the rental category id for ondemand menu
    I open '${rent_category_id}'

Retrieve the rental category id for ondemand menu
    [Documentation]    This keyword retrieves the language mapped rent tag saved in the ${RENT_IDS_DICTIONARY} variable
    ...    for the On Demand menu and returns it.
    ${status}    run keyword and return status    dictionary should contain key    ${RENT_IDS_DICTIONARY}    ${OSD_LANGUAGE}
    should be true    ${status}    RENT_IDS_DICTIONARY doesn't contain ${OSD_LANGUAGE} configuration
    ${rent_tag}    get from dictionary    ${RENT_IDS_DICTIONARY}    ${OSD_LANGUAGE}
    [Return]    ${rent_tag}

I open show all tile in vod
    [Documentation]    This keyword opens show all section in vod, under the already opened category.
    I focus Show all in VOD
    I press    OK
    VOD Grid Screen is shown
    wait until keyword succeeds    10s    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_gridCounter' contains 'textValue:^.+$' using regular expressions

I see 'Continue Watching' listed in Discover section of Ondemand screen
    [Documentation]    This keyword verifies that the 'Continue Watching' section is shown in the On Demand 'Discover'
    ...    screen, saving the focused elements in the ${CONTINUE_WATCHING_JSON} variable.
    I wait for ${MOVE_ANIMATION_DELAY} ms
    : FOR    ${i}    IN RANGE    10
    \    Move Focus to direction and assert    DOWN
    \    ${data}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser_collection_\\d+    data    ${True}
    \    ${continue_watching_collection_is_present}    Is In Json    ${data}    ${EMPTY}    id:${DISCOVER_CONTINUE_WATCHING_COLLECTION_ID}
    \    Exit For Loop If    ${continue_watching_collection_is_present}
    Should be True    ${continue_watching_collection_is_present}    Continue Watching tile not found in Discover section of Ondemand menu
    set test variable    ${CONTINUE_WATCHING_JSON}    ${LAST_FETCHED_FOCUSED_ELEMENTS}

I open the 'Automation' section in On Demand
    [Documentation]    This keyword opens the On Demand screen from anywhere, and navigates to the 'Automation' section
    ...    Precondition: The customer must have the correct products from the ${AUTOMATION_NEEDED_PRODUCTS} variable
    ...    entitled for the 'Automation' section to appear.
    I open On Demand through Main Menu
    I open 'Automation'

I focus entitled VOD movie asset
    [Documentation]    This keyword focuses an entitled VOD movie asset tile from the 'Automation' section in On Demand
    ...    and saves the asset title and crid in the ${TILE_TITLE} and ${TILE_CRID} test variables.
    ...    Precondition: The customer must have the correct products from the ${AUTOMATION_NEEDED_PRODUCTS} variable
    ...    entitled for the 'Automation' section to appear.
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${movie_details}    Get Content    ${LAB_CONF}    Automation    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}    all
    ${entitled_title}    Get VOD entitled asset title    ${movie_details}
    set test variable    ${TILE_TITLE}    ${entitled_title}
    Move Focus to Collection with Tile    ${TILE_TITLE}    title
    Move Focus to Tile    ${TILE_TITLE}    title
    ${TILE_CRID}    Get Focused Tile
    set test variable    ${TILE_CRID}

Get VOD entitled asset title
    [Arguments]    ${vod_assets}    ${subscription}=${None}
    [Documentation]    This keyword searches and returns the title of a VOD entitled asset in the list of elements given
    ...    in the ${vod_assets} parameter. If no ${subscription} parameter is provided, Subscription and Transactional
    ...    offers are considered. If ${subscription} is True only titles with Subscription offers will be returned,
    ...    if False only titles with Transactional offers will be returned.
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    : FOR    ${asset}    IN    @{vod_assets}
    \    ${asset_details}    get asset by crid    ${LAB_CONF}    ${asset['id']}    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    \    ...    ${CUSTOMER_ID}    ${CPE_ID}
    \    ${has_correct_offer}    VOD asset has correct offer type    ${asset_details}    ${subscription}    ${True}
    \    ${asset_title}    set variable if    ${has_correct_offer}    ${asset_details['title']}    ${EMPTY}
    \    Exit For Loop If    ${has_correct_offer}
    should be true    ${has_correct_offer}    No suitable entitled VOD asset was found
    [Return]    ${asset_title}

VOD asset has correct offer type
    [Arguments]    ${asset_details}    ${subscription}    ${must_be_entitled}
    [Documentation]    This keyword verifies the correct type of offer is offered for the VOD asset given in the
    ...    ${asset_details} parameter. If ${subscription} is True only Subscription offers will be valid, if False only
    ...    Transactional offers will be valid, and if None is passed, both types of offers will be considered.
    ...    If ${must_be_entitled} is True at least one offer needs to be entitled, if False no offer has to be entitled
    ...    for the asset to be considered valid.
    ${has_correct_offer_type}    Set Variable    ${False}
    ${is_asset_entitled}    Is In Json    ${asset_details}    ${EMPTY}    entitled:true
    return from keyword if    ${is_asset_entitled} and ${must_be_entitled} == ${False}
    ${offer_type}    Set variable if    ${subscription}    Subscription    Transaction
    ${offers_available}    Extract Value For Key    ${asset_details}    ${EMPTY}    offers
    : FOR    ${offer}    IN    @{offers_available}
    \    ${is_offer_entitled}    Is In Json    ${offer}    ${EMPTY}    entitled:true
    \    ${is_offer_type}    Is In Json    ${offer}    ${EMPTY}    type:${offer_type}
    \    ${has_correct_offer_type}    Evaluate    (${is_offer_type} == ${True} or ${subscription} is ${None}) and ${is_offer_entitled} == ${must_be_entitled}
    \    Exit For Loop If    ${has_correct_offer_type}
    [Return]    ${has_correct_offer_type}

BACK TO TOP is focused implementation
    [Documentation]    This keyword succeeds only if BACK TO TOP button is focused.
    ${is_focused}    Is Back to top focused
    Should be true    ${is_focused}    Back to top is not focused

Get source resolution
    [Documentation]    This keyword gets the resolution of current playing asset
    ...    Precondition: Video asset should be playing
    return from keyword if    '${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400'    ${SELENE_DEFAULT_RESOLUTION}
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    wait until keyword succeeds    3x    2s    Remote.login    ${STB_IP}    ${ssh_handle}
    ${cmd_output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    cat /proc/brcm/video_decoder
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    ${line}    Get Lines Containing String    ${cmd_output}    Source:
    ${source_resolution}    Fetch From Right    ${line}    Source:
    [Return]    ${source_resolution}

Get VOD duration
    [Documentation]    This keyword gets the duration of the selected VOD and returns it
    ...    Precondition: Detail page screen should be open.
    wait until keyword succeeds    5times    1s    I expect focused elements contains 'id:detailPageList'
    ${json_object}    get ui json
    ${hours_duration_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_GENERIC_DURATION_HRS_MIN
    ${mins_duration_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_GENERIC_DURATION_MIN
    should be true    ${hours_duration_present} or ${mins_duration_present}    Duration is not defined in details page
    ${duration_textkey}    set variable if    ${hours_duration_present}    DIC_GENERIC_DURATION_HRS_MIN    DIC_GENERIC_DURATION_MIN
    ${duration_str}    Extract Value For Key    ${json_object}    textKey:${duration_textkey}    textValue
    ${vod_duration}    get regexp matches    ${duration_str}    \\d+ min
    ${vod_duration}    Remove String Using Regexp    ${vod_duration[0]}    \\D
    [Return]    ${vod_duration}

Move focus to last episode in last season
    [Documentation]    This keyword focuses the last episode in the last season
    ...    Precondition: Episode picker screen should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:EzyListepisodeList'
    ${last_season}    Get number of 'seasons' from Episode picker
    wait until keyword succeeds    20times    3s    Make sure that focus is on    season    ${last_season}
    ${last_episode}    Get number of 'episodes' from Episode picker
    wait until keyword succeeds    20times    3s    Make sure that focus is on    episode    ${last_episode}

Get focused '${type}' number
    [Documentation]    This keyword gets the number of focused episode or season identified by the ${type} argument and returns ${type_number}.
    ...    Argument ${type} allowed value is 'episode' or 'season'.
    ...    Precondition: Episode picker page screen should be open.
    ${type_list}    set variable if    '${type}' == 'episode'    ${EPISODE_ONDEMAND_VARIABLES_LIST}    ${SEASON_ONDEMAND_VARIABLES_LIST}
    Move to element assert focused elements    id:${type_list[0]}    2    ${type_list[1]}
    ${json_object}    Get Ui Json
    ${type_title}    Extract Value For Key    ${json_object}    id:subTitleInfo    textValue
    ${type_number}    run keyword if    '${type}' == 'episode'    Get episode focused number for ${type_title}
    ...    ELSE IF    '${type}' == 'season'    Get season focused number for ${type_title}
    [Return]    ${type_number}

Make sure that focus is on
    [Arguments]    ${type}    ${number}
    [Documentation]    This keyword move the focus to an episode or a season number identified by the ${number} argument
    ...    Argument ${type} allowed value is 'episode' or 'season'.
    ...    Precondition: Episode picker page screen should be open.
    ${focused_position}    Get focused '${type}' number
    Return from keyword if    ${focused_position} == ${number}
    I Press    DOWN
    Focus is on    ${type}    ${number}

Focus is on
    [Arguments]    ${type}    ${number}
    [Documentation]    This keyword asserts if ${type} is focused on a correct number identified by the ${number} argument
    ...    Argument ${type} allowed value is 'episode' or 'season'.
    ...    Precondition: Episode picker page screen should be open.
    ${focused_position}    Get focused '${type}' number
    Should Be Equal    ${focused_position}    ${number}    The ${type} ${number} is not focused

Get number of '${type}' from Episode picker
    [Documentation]    This keyword gets the number of episodes or seasons identified by the ${type} argument and returns it.
    ...    Argument ${type} allowed value is 'episodes' or 'seasons'.
    ...    Precondition: Episode picker page screen should be open.
    ${type_list}    set variable if    '${type}' == 'episodes'    ${EPISODE_ONDEMAND_VARIABLES_LIST}    ${SEASON_ONDEMAND_VARIABLES_LIST}
    Move to element assert focused elements    id:${type_list[0]}    2    ${type_list[1]}
    ${list}    Retrieve '${type}' list
    ${number_of_elements}    get length    ${list}
    ${number_of_elements}    set variable if    '${type}' == 'episodes'    ${number_of_elements}    ${number_of_elements-1}
    Should Be True    ${number_of_elements} > 0    There are no ${type}
    [Return]    ${number_of_elements}

Retrieve '${type}' list
    [Documentation]    This keyword retrieves the list of episodes or seasons identified by the ${type} argument and returns it.
    ...    Argument ${type} allowed value is 'episodes' or 'seasons'.
    ...    Precondition: Episode picker page screen should be open.
    ${type_list}    set variable if    '${type}' == 'episodes'    ${EPISODE_ONDEMAND_VARIABLES_LIST}    ${SEASON_ONDEMAND_VARIABLES_LIST}
    @{items_list}    I retrieve value for key 'data' in focused element 'id:${type_list[0]}'
    Should Not Be Empty    ${items_list}    Failed at retrieving ${type} list
    &{dict}    Create Dictionary
    : FOR    ${child}    IN    @{items_list}
    \    run keyword if    '${type}' == 'episodes'    Set To Dictionary    ${dict}    ${child['id']}=${child}
    \    ...    ELSE    Set To Dictionary    ${dict}    ${child['title']}=${child}
    ${items_list}    Get Dictionary Keys    ${dict}
    [Return]    ${items_list}

Get episode focused number for ${type_title}
    [Documentation]    This keyword gets the number of focused episode title identified by the ${type_title} and returns ${episode_number}.
    ${episode_number}    get regexp matches    ${type_title}    .+\\d+ -
    ${episode_number}    Remove String Using Regexp    ${episode_number[0]}    \\D+
    Should be True    '${episode_number}' != '${None}'    Failed at retrieving ${type} number
    [Return]    ${episode_number}

Get season focused number for ${type_title}
    [Documentation]    This keyword gets the number of focused season title identified by the ${type_title} and returns ${season_number}.
    ${season_number}    Remove String Using Regexp    ${type_title}    \\D+
    ${season_number}    Convert To Integer    ${season_number}
    Should be True    '${season_number}' != '${None}'    Failed at retrieving ${type} number
    [Return]    ${season_number}

Navigate to unentitled TVOD asset    #USED
    [Documentation]    This keyword attempts to navigate to an unentitled single TVOD asset from the VOD section
    ...    of the On Demand screen. If parameter multiple_quality is 'True', navigates to only the vod aset with multiple instances
    ...    to choose from while renting. If 'Any' such filter based on instances is not applied.
    [Arguments]  ${multiple_quality}=Any
    ${multiple_quality}    Set Variable If    "${multiple_quality}"=="${True}"    ${True}    ${False}
    ${section_name}    ${unentitled_assets}    Find Unentitled TVOD Assets Belonging To A VOD Section    ${multiple_quality}
    ${type_string}    Run Keyword If    ${multiple_quality}    Evaluate     type($unentitled_assets).__name__
    ${unentitled_asset_names}    Run Keyword If    "${type_string}"=="DotDict"    Get Dictionary Keys    ${unentitled_assets}
    ...    ELSE    Set Variable    ${unentitled_assets}
    ${random_tvod_title}    Get Random Element From Array    ${unentitled_asset_names}
    Set Suite Variable    ${RENTED_MOVIE_TITLE}    ${random_tvod_title}
    Set Suite Variable    ${VOD_SECTION_WITH_REQUIRED_ASSET}    ${section_name}
    Run Keyword If    ${multiple_quality}    Set Suite Variable    ${VOD_INSTANCES}    ${unentitled_assets['${random_tvod_title}']}
    I open '${section_name}'
    I Press    DOWN
    I focus '${RENTED_MOVIE_TITLE}' tile

Find Unentitled TVOD Assets Belonging To A VOD Section    #USED
    [Documentation]    This keyword attempts to find unentitled single TVOD assets from a VOD section
    ...    of the On Demand screen. If parameter multiple_quality is 'True', navigates to only the single vod asset with multiple instances
    ...    to choose from while renting. If 'Any' such filter based on instances is not applied.
    ...    Providers and sections containing series VOD assets are skipped
    [Arguments]  ${multiple_quality}=Any
    ${multiple_quality}    Set Variable If    "${multiple_quality}"=="${True}"    ${True}    ${False}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Retrieve VOD Root Category Structure From Backend
    :FOR    ${section_name}    IN    @{VOD_SECTIONS_DICTIONARY.keys()}
    \    Log    ${section_name}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    ${provider_name}    Get Tenant Specific Name For Providers Section    ${False}
    \    ${provider_name}    Run Keyword If    '''${provider_name}'''!='''${None}'''    Convert To Lowercase    ${provider_name}
    \    Run Keyword If    '''${provider_name}'''!='''${None}'''    Continue For Loop If    '''${section_name}'''=='''${provider_name}'''
    \    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all
    \    Continue For Loop If    not ${movies_details}
    \    ${unentitled_assets}    Get TVOD non-entitled asset title    ${movies_details}    ${multiple_quality}
    \    ${assets_found}    Run Keyword And Return Status    Should Not Be Empty    ${unentitled_assets}
    \    Exit For Loop If    ${assets_found}
    Should Not Be Empty    ${unentitled_assets}    Unentitled TVOD assets not found
    [Return]    ${section_name}    ${unentitled_assets}

Navigate To Age Rated Vod Asset    #USED
    [Arguments]    ${only_tvod}=False
    [Documentation]    This keyword attempts to navigate to an age rated single Vod Asset from the VOD section
    ...    of the On Demand screen.
    ${section_name}    ${vod_asset_list}    Find Age Rated VOD Assets Belonging To A VOD Section    ${only_tvod}
    ${random_vod_details}    Get Random Element From Array    ${vod_asset_list}
    Set Suite Variable    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${random_vod_details}
    Set Suite Variable    ${AGE_RATED_MOVIE_TITLE}    ${random_vod_details['title']}
    Set Suite Variable    ${NAVIGATE_TO_AGE_RATED_VOD_ASSET}    ${True}
    ${crid}    Get Asset Crid From Vodscreen Response Of An Asset    ${random_vod_details}
    Set Suite Variable    ${LAST_FETCHED_VODSCREEN_RESPONSE_CRID}    ${crid}
    I open '${section_name}'
    I press    DOWN
    I focus '${AGE_RATED_MOVIE_TITLE}' tile

Find Age Rated VOD Assets Belonging To A VOD Section    #USED
    [Arguments]    ${only_tvod}=False
    [Documentation]    This keyword attempts to navigate Age Rated Single Vod Asset from the VOD section
    ...    of the On Demand screen.
    ...    Providers and sections containing series VOD assets are skipped
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Retrieve VOD Root Category Structure From Backend
    :FOR    ${section_name}    IN    @{VOD_SECTIONS_DICTIONARY.keys()}
    \    Log    ${section_name}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    ${provider_name}    Get Tenant Specific Name For Providers Section    ${False}
    \    ${provider_name}    Run Keyword If    '''${provider_name}'''!='''${None}'''    Convert To Lowercase    ${provider_name}
    \    Run Keyword If    '''${provider_name}'''!='''${None}'''    Continue For Loop If    '''${section_name}'''=='''${provider_name}'''
    \    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all    collection    ${None}    popularity    ${False}
    \    Continue For Loop If    not ${movies_details}
    \    ${vod_asset_list}    Get Age Rated VOD asset title    ${movies_details}    ${only_tvod}
    \    ${title_is_not_empty}    Run Keyword And Return Status    Should Not Be Empty    ${vod_asset_list}
    \    Exit For Loop If    ${title_is_not_empty}
    Should Not Be Empty    ${vod_asset_list}    Age rated VOD assets not found
    [Return]    ${section_name}    ${vod_asset_list}

Get Age Rated VOD asset title    #USED
    [Arguments]    ${vod_section}    ${only_tvod}=False
    [Documentation]    This keyword searches and returns the title of a Age Rated single VOD asset as per the requirement of ${only_tvod} in the given ${vod_section}
    ...    eg. if ${only_tvod} is True then this keyword will return the Age rated Tvod asset
    ...    else then this keyword will return the Age rated asset that can be SVOD or asset which is already been purchased
    ${watershed_age_rating}    Get Maximum Allowed Age Rating For Watershed Lane
    ${vod_asset_list}    Create List
    ${number_assets}    Get Length    ${vod_section}
    ${get_age}    Get application service setting    profile.ageLock
    ${get_age}    Set Variable If    '${watershed_age_rating}'!='${None}'    ${watershed_age_rating}    ${get_age}
    Run Keyword If    ${get_age}==${-1}    Set Suite variable    ${CURRENT_WATERSHED_LANE_NO_AGE_RESTRICTION}    ${True}
    ${asset_title}    Set Variable    ${EMPTY}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    : FOR    ${i}    IN RANGE    ${0}    ${number_assets}
    \    log  ${vod_section[${i}]}
    \    ${crid_id}    Get Asset Crid From Vodscreen Response Of An Asset    ${vod_section[${i}]}
    \    ${asset_details}    get asset by crid    ${LAB_CONF}    ${crid_id}    ${COUNTRY}    ${OSD_Language}    ${cpe_profile_id}
    \    ...    ${CUSTOMER_ID}
    \    ${is_tvod}    Is In Json    ${asset_details}    ${EMPTY}    type:Transaction    ${EMPTY}
    \    ...    ${True}
    \    ${is_tvodentitledEnd}    Is In Json    ${asset_details}    ${EMPTY}    tvodEntitlementEnd:    ${EMPTY}
    \    ...    ${True}
    \    ${is_agerated}    Is In Json    ${asset_details}    ${EMPTY}    ageRating:    ${EMPTY}
    \    ...    ${True}
    \    ${entitlement}    Set Variable If    ${only_tvod}    False    True    #this variable is used whether we want rented or un-rented Tvod if ${only_tvod} is true that mean requirement if of unrented TVOD
    \    ${is_4K}    Check Whether VOD Asset Has Multiple Instances From Asset Details    ${asset_details}    ${True}
    \    Continue For Loop If    ${is_4K}
    \    ${duration}    Extract Value For Key    ${asset_details}    ${EMPTY}    duration
    \    ${valid}    Set Variable If    ${duration}>${0}    ${True}    ${False}
    \    Continue For Loop If    ${valid}==${False}
    \    Continue For Loop If    "${is_agerated}"=="False"
    \    Continue For Loop If    "${only_tvod}"=="True" and "${is_tvod}"=="False"
	\    Run Keyword If    ${is_tvod}    Continue For Loop If    "${is_tvodentitledEnd}"!="${entitlement}"
    \    Set Test Variable  ${asset_age_rating}    ${asset_details['ageRating']}
    \    ${asset_title}    Set Variable If  ('${watershed_age_rating}'=='${None}' and ${asset_age_rating}> ${get_age}) or ('${watershed_age_rating}'!='${None}' and ${asset_age_rating}>= ${get_age})    ${vod_section[${i}]['title']}    ${EMPTY}
    \    ${title_is_not_empty}    Run Keyword And Return Status    Should Not Be Empty    ${asset_title}    VOD asset with given duration is not found
    \    Run Keyword If    ${title_is_not_empty}    Append To List    ${vod_asset_list}    ${vod_section[${i}]}
    [Return]    ${vod_asset_list}

Navigate To VOD Asset With Trailer    #USED
    [Documentation]    This keyword attempts to navigate to a single VOD asset that has a trailer from any section in on demand
    ${section_name}    ${trailer_assets}    Find VOD Assets With Trailer Belonging To A VOD Section
    ${random_vod_title}    Get Random Element From Array    ${trailer_assets}
    Set Test Variable    ${VOD_WITH_TRAILER}    ${random_vod_title}
    I open '${section_name}'
    I Press    DOWN
    I focus '${VOD_WITH_TRAILER}' tile

Find VOD Assets With Trailer Belonging To A VOD Section    #USED
    [Documentation]    This keyword fetches title of a single VOD asset from any of the sections in On Demand
    ...    Providers and sections containing series VOD assets are skipped
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Retrieve VOD Root Category Structure From Backend
    :FOR    ${section_name}    IN    @{VOD_SECTIONS_DICTIONARY.keys()}
    \    Log    ${section_name}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    ${provider_name}    Get Tenant Specific Name For Providers Section    ${False}
    \    ${provider_name}    Run Keyword If    '''${provider_name}'''!='''${None}'''    Convert To Lowercase    ${provider_name}
    \    Run Keyword If    '''${provider_name}'''!='''${None}'''    Continue For Loop If    '''${section_name}'''=='''${provider_name}'''
    \    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all
    \    Continue For Loop If    not ${movies_details}
    \    ${trailer_assets}    Get Title Of A VOD Asset With Trailer    ${movies_details}
    \    ${assets_found}    Run Keyword And Return Status    Should Not Be Empty    ${trailer_assets}
    \    Exit For Loop If    ${assets_found}
    Should Not Be Empty    ${trailer_assets}    Vod Asset with trailer not found.
    [Return]    ${section_name}    ${trailer_assets}

Get Title Of A VOD Asset With Trailer    #USED
    [Arguments]    ${vod_section}
    [Documentation]    This keyword searches and returns the title of a single VOD asset with trailer
    ...    in the given ${vod_section}.
    ${number_assets}    Get Length    ${vod_section}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${trailer_assets}    Create List
    : FOR    ${i}    IN RANGE    ${0}    ${number_assets}
    \    ${crid_id}    Get Asset Crid From Vodscreen Response Of An Asset    ${vod_section[${i}]}
    \    ${asset_details}    get asset by crid    ${LAB_CONF}    ${crid_id}    ${COUNTRY}    ${OSD_Language}    ${cpe_profile_id}
    \    ...    ${CUSTOMER_ID}
    \    ${is_trailer_present}    Is In Json    ${asset_details}    ${EMPTY}    trailers:    ${EMPTY}
    \    ...    ${True}
    \    Run Keyword If    ${is_trailer_present}    Append To List    ${trailer_assets}    ${vod_section[${i}]['title']}
    [Return]    ${trailer_assets}

Validate The First Genre Tile In On Demand Section    #USED
    [Documentation]    This keywords selects the first genre tile in Movies Page
    ...    and creates a dictionary containing all genre titles and cred ids. Returns selected genre title
    I Press    DOWN
    ${genre_tile_focused}    Focus On First Genre Tile In On Demand Section
    Should Be True    ${genre_tile_focused}    'Genre tiles are not present'
    ${focused_elements}    Get Ui Focused Elements
    ${genres}    ${number}    Get Current Collection Tiles
    ${selected_genre}    Get Random Element From Array    ${genres}
    ${index}    Get Index From List    ${genres}    ${selected_genre}
    Move To Element Assert Focused Elements Using Regular Expression    id:shared-CollectionsBrowser_collection_\\\\d+_tile_${index}
    ...    ${number}    RIGHT
    Set Suite Variable    ${GENRE_DICTIONARY}    ${genres}
    I Press    OK
    ${adult_section_popup}    Run Keyword And Return Status    Adult Section Pin Entry Modal Is Shown
    Run Keyword If    ${adult_section_popup}    I enter a valid pin
    Set Suite Variable    ${ADULT_SECTION_SELECTED}    ${adult_section_popup}
    Set Suite Variable  ${SELECTED_GENRE}    ${selected_genre}

Focus On First Genre Tile In On Demand Section    #USED
    [Documentation]    This keyword moves the focus to first genre tile in 'Movies' page
    : FOR    ${_}    IN RANGE    ${20}
    \    I wait for ${MOVE_ANIMATION_DELAY} ms
    \    ${focused_elements}    Get Ui Focused Elements
    \    ${elem_is_focused}    Is In Json    ${focused_elements}    id:shared-CollectionsBrowser_collection_\\d+    title:^((Tile$|TILE$|tile$)|([Mm][Oo][Vv][Ii][Ee] )?([gG][eE][nN][rR][eE](?:$|[sS])))    ${EMPTY}
    \    ...    ${True}
    \    Exit For Loop If    ${elem_is_focused}
    \    ${back_to_top}    Is In Json    ${focused_elements}    id:shared-BackToTop    textKey:DIC_BACK_TO_TOP
    \    Exit For Loop If    ${back_to_top}
    \    I Press    DOWN
    [Return]    ${elem_is_focused}

Validate Genre Filter For The Selected Genre    #USED
    [Documentation]    This keyword validates the filter results not being empty and are displayed according to selected genre
    ${current_country_code}    get country code from stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    Variable Should Exist    ${SELECTED_GENRE}    Genre tile currently selected is not saved
    ${is_adult}    Run Keyword And Return Status    Should Be True    ${ADULT_SECTION_SELECTED}
    Return From Keyword If    ${is_adult}
    Run Keyword If    '''${SELECTED_GENRE['title']}'''=='''View All'''
    ...    Set To Dictionary    ${SELECTED_GENRE}    title    Show All
    ...    ELSE IF    '${current_country_code}' == 'CH' and '''${SELECTED_GENRE['title']}'''=='''Romance'''
    ...    Set To Dictionary    ${SELECTED_GENRE}    title    Romantic Films
    Wait Until Keyword Succeeds    10s    1s    I expect page contains 'textKey:DIC_SORT_POPULARITY'
    Error popup is not shown
    I Press    MENU
    ${current_focus}    Get Ui Focused Elements
    ${dropdown_check}    Is In Json    ${current_focus}    id:gridNavigation_filterButton_0
    ...    textKey:DIC_FILTER_AVAILABILITY
    ${genre_selection_dropdown_presence}    Set Variable If    ${dropdown_check}    ${False}    ${True}
    ${picker_genre}    Extract Value For Key    ${current_focus}    id:gridNavigation_filterButton_0    textValue
    I Press    DOWN
    ${ui_json}    Get Ui Json
    ${secondary_title}    Run Keyword If    not ${genre_selection_dropdown_presence}    Extract Value For Key    ${ui_json}    id:mastheadSecondaryTitle
    ...    textValue
    Set Suite Variable    ${GENRE_SELECTION_DROPDOWN_PRESENCE}    ${genre_selection_dropdown_presence}
    Run Keyword If    '${secondary_title}'!='${None}'    Should Contain    ${secondary_title}    ${SELECTED_GENRE['title']}
    ...    ELSE    Should Be Equal As Strings    ${picker_genre}    ${SELECTED_GENRE['title']}    ignore_case=True
    ${tiles}    ${number_of_movies}     Get Current Collection Tiles
    ${type_string}    Evaluate     type($tiles).__name__
    Should Not Be True    '${type_string}' == 'str'    'No asset found for given genre'

Select A Genre Randomly From Genre Picker    #USED
    [Documentation]    This keyword selects a genre randomly from the genre picker
    Variable Should Exist    ${ADULT_SECTION_SELECTED}    boolean to indicate whether adult section is selected
    ${is_adult}    Run Keyword And Return Status    Should Be True    ${ADULT_SECTION_SELECTED}
    Return From Keyword If    ${is_adult}
    Variable Should Exist    ${SELECTED_GENRE}    Genre title and crid currently selected has not been saved
    Variable Should Exist    ${GENRE_SELECTION_DROPDOWN_PRESENCE}    boolean to indicate presence of dropdown to select genres not saved
    Return From Keyword If    not ${GENRE_SELECTION_DROPDOWN_PRESENCE}
    ${ui_focus}    Get Ui Focused Elements
    ${data}    Extract Value For Key    ${ui_focus}    id:shared-CollectionsBrowser    data
    ${screen_crid}    Extract Value For Key    ${data}    ${EMPTY}    id
    ${response}    I Get Gridscreen Options For Crid    ${screen_crid}
    ${filter_options}    Extract Value For Key    ${response}    ${EMPTY}    filterOptions
    ${genre_list}    Extract Value For Key    ${filter_options}    ${EMPTY}    genres
    ${current_position}    Set Variable    ${EMPTY}
    ${adult_section_position}    Set Variable    ${False}
    :FOR    ${genre}    IN    @{genre_list}
    \    ${is_equal}    Run Keyword And Return Status    Should Be Equal As Strings    ${genre['name']}    ${SELECTED_GENRE['title']}    ignore_case=True
    \    ${current_position}    Run Keyword If    ${is_equal}    Get Index From List    ${genre_list}    ${genre}
    ...    ELSE    Set Variable    ${current_position}
    \    ${is_adult}    Run Keyword And Return Status    Should Be True    ${genre['isAdult']}
    \    ${adult_section_position}    Run Keyword If    ${is_adult}    Get Index From List    ${genre_list}    ${genre}
    ...    ELSE    Set Variable    ${adult_section_position}
    ${is_adult_section_present}    Set Variable If    '''${adult_section_position}'''!='''${False}'''    ${True}    ${False}
    I Press    MENU
    I expect focused elements contains 'id:gridNavigation_filterButton_0'
    I Press    OK
    I wait for 500 ms
    ${ui_json}    Get Ui Json
    Wait Until Keyword Succeeds    3s    1s    I expect page contains 'id:value-picker-selection'
    Run Keyword If    ${is_adult_section_present}    Remove From List    ${genre_list}    ${adult_section_position}
    ${length}    Get Length    ${genre_list}
    ${temp}    Copy List    ${genre_list}
    Remove From List    ${temp}    ${current_position}
    ${genre_to_select}    Get Random Element From Array    ${temp}
    Set To Dictionary    ${genre_to_select}    title    ${genre_to_select['name']}
    Set Suite Variable    ${SELECTED_GENRE}    ${genre_to_select}
    ${position_to_navigate}    Get Index From List    ${genre_list}    ${SELECTED_GENRE}
    ${difference}    Evaluate    ${current_position}-${position_to_navigate}
    ${abs}    Evaluate    abs(${difference})
    Run Keyword If    ${abs}==${difference}    I press UP ${abs} times
    ...    ELSE    I press DOWN ${abs} times
    I Press    OK
    I wait for 500 ms
    Error popup is not shown

Select A Sort Option Randomly From All Genres Page    #USED
    [Documentation]    Selects A Sort Option randomly from All Genres Page
    ${is_adult}    Run Keyword And Return Status    Should Be True    ${ADULT_SECTION_SELECTED}
    Return From Keyword If    ${is_adult}
    Navigate To Sort Button In All Genres Page
    I Press    OK
    I wait for 1 seconds
    ${ui_json}    Get Ui Json
    ${dropdown_present}    Is In Json    ${ui_json}    ${EMPTY}    id:picker-item-text-\\d+    ${EMPTY}    ${True}
    Should Be True    ${dropdown_present}
    ${option_list}    Create List
    :FOR    ${i}    IN RANGE    0    20
    \    ${search_param}    Catenate    SEPARATOR=    id:picker-item-text-    ${i}
    \    ${option_present}    is in json    ${ui_json}    ${EMPTY}    ${search_param}    ${False}
    \    Continue For Loop If    '${option_present}' == 'False'
    \    ${option_name}    Extract Value For Key    ${ui_json}    ${search_param}    textValue    ${False}
    \    append to list    ${option_list}    ${option_name}
    Set Suite Variable    ${SORT_OPTION_LIST}    ${option_list}
    ${length}    Get Length    ${SORT_OPTION_LIST}
    ${number}    Evaluate    random.sample(range(1, $length), 1)    random
    Set Suite Variable    ${SELECTED_SORT_PICKER_POSITION}    ${number[${0}]}
    :FOR    ${key_press}    IN RANGE    0    ${number[${0}]}
    \    I Press    DOWN
    I Press    OK
    I wait for 500 ms
    Error popup is not shown

Validate Sort Results For The Selected Sort Option    #USED
    [Documentation]    Validates sort results for the selected sort option
    ${is_adult}    Run Keyword And Return Status    Should Be True    ${ADULT_SECTION_SELECTED}
    Return From Keyword If    ${is_adult}
    Variable Should Exist    ${SORT_OPTION_LIST}    The list containing sort options not saved. SORT_OPTION_LIST does not exist
    Variable Should Exist    ${SELECTED_SORT_PICKER_POSITION}    The position of the selected sort option is not saved.
    Navigate To Sort Button In All Genres Page
    ${current_focus}    Get Ui Focused Elements
    ${selected_sort}    extract value for key    ${current_focus}    id:gridNavigation_sortButton    textValue    ${False}
    List Should Contain Value    ${SORT_OPTION_LIST}    ${selected_sort}
    I Press    DOWN
    ${tiles}    ${number_of_movies}     Get Current Collection Tiles
    ${type_string}    Evaluate     type($tiles).__name__
    Should Not Be True    '${type_string}' == 'str'    'No asset found for given genre'

Navigate To Sort Button In All Genres Page    #USED
    [Documentation]    Navigates to sort button in All Genres Page
    I Press    MENU
    :FOR    ${i}    IN RANGE    0    10
    \    I wait for 500 ms
    \    ${focused_element}    Get Ui Focused Elements
    \    ${sort_present}    is in json    ${focused_element}    ${EMPTY}    id:gridNavigation_sortButton    ${EMPTY}    ${False}
    \    Run Keyword If    '${sort_present}' == 'False'    I Press    RIGHT
    \    Exit For Loop If    ${sort_present}
    Should Be True    ${sort_present}    'sort button not found'

Validate Because You Watched Section    #USED
    [Documentation]    This keyword Validates Reng recommended TVOD assets from the VOD section of the On Demand screen
    ...    Prerequisites - On Demand Section Should Be Opened
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    :FOR    ${screen}    IN    @{VOD_SECTION_IDS_DICTIONARY.keys()}
    \    Continue For Loop If    '${screen}' == 'x'
    \    ${provider_name}    Get Tenant Specific Name For Providers Section    ${False}
    \    ${is_provider}    Run Keyword If    '''${provider_name}'''!='''${None}'''
    ...    Run Keyword And Return Status    Should Be Equal As Strings    ${screen}    ${provider_name}    ignore_case=True
    ...    ELSE    Set Variable    ${False}
    \    Continue For Loop If    ${is_provider}
    \    ${structure_json}    Get Vod Full Vod Structure
    \    ${screen_details}    Get Vod Screen From Screen Title    ${structure_json}    ${screen}    ${True}
    \    Log    ${screen_details}
    \    ${is_reng_section}    Find Because You Watched Section    ${screen_details}
    \    Exit For Loop If    ${is_reng_section}
    Should Be True    ${is_reng_section}    Could not find because you watched recommendations for watched asset
    Validate Reng recommendation Tiles    ${screen}

Find Because You Watched Section    #USED
    [Documentation]    This Keyword Searches For RENG Recommended Section In On Demand
    ...    Arguments - Dictionary containing Vod Tile Screen Details Of A Node
    [Arguments]    ${screen_details}
    :FOR    ${collection}    IN    @{screen_details['collections']}
    \    ${is_found}    Evaluate    bool(re.match('Because you watched',$collection['title']))    modules=re
    \    Exit For Loop If    ${is_found}
    ${max_retries}    Get Length    ${screen_details['collections']}
    Set Suite Variable    ${MAX_RETRIES}    ${max_retries}
    [Return]    ${is_found}
    
Validate Reng recommendation Tiles    #USED
    [Documentation]    This Keyword Validates The Reng Recommended Assets Section and Tiles in Given Section
    [Arguments]    ${SECTION}
    I open '${SECTION}'
    :FOR    ${INDEX}    IN RANGE    0    ${MAX_RETRIES}
    \    I Press    DOWN
    \    I wait for ${5} seconds
    \    ${UI_FOCUSSED}    Get Ui Focused Elements
    \    ${IS_RENG_SECTION}    Evaluate    bool(re.match('Because you watched',$UI_FOCUSSED[1]['data']['title']))    modules=re
    \    Exit For Loop If    ${IS_RENG_SECTION} == ${True}
    Should Be True    ${IS_RENG_SECTION}    Reng Recommended Asset Tiles Are Not In Focus
    :FOR    ${ITEM}    IN    @{UI_FOCUSSED[1]['data']['items']}
    \    Should Not Be Equal    ${ITEM['id']}    ${None}
    \    Should Not Be Equal    ${ITEM['title']}    ${None}

Play Already Purchased VOD Asset And Verify Playback    #USED
    [Documentation]    This keyword plays an already purchased VOD and verifies playback. Pin entry popup is handled for age restricted VOD
    ...    and Continue Watching Popup is handled to play from start. Precondition: VOD Details page is opened
    First action is focused
    :FOR    ${i}    IN RANGE    0    ${2}
    \    ${page_before_ok_press}    Get Ui Json
    \    I Press    OK
    \    I wait for 300 ms
    \    ${page_after_ok_press}    Get Ui Json
    \    ${is_page_changed}    Run Keyword And Return Status    Check If Jsons Are Different    ${page_before_ok_press}    ${page_after_ok_press}
    \    Exit For Loop If    ${is_page_changed}
    Should Be True    ${is_page_changed}    OK key press missed even after retries
    Handle Popup And Pin Entry During Playback of an Already Purchased VOD Asset
    Validate Asset is Playing in Player And Exit Playback

Return Random VOD Title In VOD Grid Page    #USED
    [Documentation]    This keyword returns a random VOD Title from the Rented Page
    ${ui_focus}    Get Ui Focused Elements
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${asset_list}   Extract Value For Key    ${ui_focus}    ${EMPTY}    items    ${False}
    ${number_of_assets}    Get Length    ${asset_list}
    ${asset_details_dictionary}    Create Dictionary
    :FOR    ${i}    IN RANGE    0    ${number_of_assets}
    \    ${asset_details}    get asset by crid    ${LAB_CONF}    ${asset_list[${i}]['id']}    ${COUNTRY}    ${OSD_Language}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}
    \    ${invalid_details}    Run Keyword And Return Status    Dictionary Should Contain Key    ${asset_details}    error
    \    Continue For Loop If    ${invalid_details}
    \    ${resolution}    Extract Value For Key    ${asset_details}    ${EMPTY}    resolution    ${False}
    \    Continue For Loop If    "${resolution}"=="4K"
    \    ${duration}    Extract Value For Key    ${asset_details}    ${EMPTY}    duration
    \    ${valid}    Set Variable If    ${duration}>${0}    ${True}    ${False}
    \    Continue For Loop If    ${valid}==${False}
    \    ${asset_dictionary}    Create Dictionary
    \    Run Keyword If    ${valid}    Run Keywords    Set To Dictionary    ${asset_dictionary}    title    ${asset_list[${i}]['title']}
    ...    id    ${asset_list[${i}]['id']}    AND    Set To Dictionary    ${asset_details_dictionary}    ${i}    ${asset_dictionary}
    ${indices}    Get Dictionary Keys    ${asset_details_dictionary}
    Should Not Be Empty    ${indices}    VOD Assets with specified filters not available in Rented section
    ${index}    Get Random Element From Array    ${indices}
    [Return]    ${asset_details_dictionary[${index}]['title']}    ${asset_details_dictionary[${index}]['id']}

Handle Popup And Pin Entry During Playback of an Already Purchased VOD Asset    #USED
    [Documentation]    This keyword handles pin entry popup for age restricted assets and continue watching popup
    ...     by selecting play from start action if required. Verifies any popup related to renting is absent.
    I Do Not Expect Rental Options For An Already Purchased VOD Asset
    ${limited_entitlement}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 times    1s
    ...    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_LIMITED_ENTITLEMENT_MESSAGE'
    Run Keyword If    ${limited_entitlement}    I Press    OK
    ${pin_entry_present}    Run Keyword And Return Status    Age Restricted PIN Entry Popup Is Shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin
    I Handle Watch Popup Screens And Any Warning Screen For Already Purchased VOD Asset

I Do Not Expect Rental Options For An Already Purchased VOD Asset    #USED
    [Documentation]    This keyword verifies that popup related to renting do not show up for an already purchased asset
    Wait Until Keyword Succeeds    5    1s    I do not expect page contains 'textKey:DIC_GENERIC_RENT'
    Wait Until Keyword Succeeds    5    1s    I do not expect page contains 'textKey:DIC_PURCHASE_PIN_ENTRY_MESSAGE'

Set Profile Bookmarks For A VOD Asset With Given Percentage    #USED
    [Documentation]    This keyword sets bookmark based on profile id for VOD Asset whose crid id is saved in LAST_FETCHED_VOD_ASSET
    ...   or given explicitly by calculating bookmark_position based on asset duration.
    [Arguments]    ${percentage}=${0}    ${crid}=${LAST_FETCHED_VOD_ASSET}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${info}    I Get Details Of A VOD Asset With Given Crid Id    ${crid}    ${cpe_profile_id}
    ${duration}    Extract Value For Key    ${info}    ${EMPTY}    duration    ${False}
    Set Profile Bookmark For An Asset Based On Percentage    vod    ${crid}
    ...    ${duration}    ${percentage}    ${cpe_profile_id}

Continue Watching Selected VOD Asset And Get Progress Bar Indicator Data     #USED
    [Documentation]    This keyword ensures that the selected VOD asset is partially watched. If its a TVOD asset, it is rented.
    ...    Rental and age restricted pin entry popup are handled. 'Continue Watching' is selected when prompted. Plays out the video for 30 seconds.
    ...    Time where playout is stopped is saved. Precondition: VOD details page is opened.
    Continue Watching Selected Asset From Detail Page
    make sure Playout continues for the duration    ${30}s
    I switch Player to PAUSE mode
    ${CONTINUE_WATCHING_PROGRESS_TIME}    ${_}    Get viewing progress indicator data
    I press    STOP
    Set Suite Variable    ${CONTINUE_WATCHING_PROGRESS_TIME}

Verify Provider Tiles In Providers Section    #USED
    [Documentation]    This keyword navigates to every provider tile in providers section and checks whether
    ...    appropriate second level screen is opened with no error popup. Precondition: Providers section is open
    I Press    DOWN
    ${focused_node}    Get Ui Focused Elements
    ${providers_list}    Extract Value For Key    ${focused_node}    id:shared-CollectionsBrowser    data    ${False}
    ${length}    Get Length    ${providers_list}
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${focused_node}    Get Ui Focused Elements
    \    ${provider_title_focused}    Extract Value For Key    ${focused_node}    id:shared-CollectionsBrowser_collection_\\d+_tile_\\d+
    ...    data    ${True}
    \    Should Be Equal As Strings    ${providers_list[${i}]['title']}    ${provider_title_focused['title']}
    \    I Press    OK
    \    Error popup is not shown
    \    ${focused_tile}    Get Ui Focused Elements
    \    ${provider_sections}    Is In Json    ${focused_tile}    ${EMPTY}    id:shared-SectionNavigation
    \    ${provider_grids}    Is In Json    ${focused_tile}    ${EMPTY}    id:shared-GridNavigation
    \    Run Keyword If    ${provider_sections} or ${provider_grids}    I Press    DOWN
    \    ${focused_tile}    Get Ui Focused Elements
    \    ${ui_json}    Get Ui Json
    \    ${title}    Extract Value For Key    ${ui_json}    id:mastheadSecondaryTitle    textValue
    \    Should Contain    ${title}    ${providers_list[${i}]['title']}    Appropriate second level screen did not open for
    ...    ${providers_list[${i}]['title']}
    \    ${no_match}    Is In Json    ${ui_json}    ${EMPTY}    textKey:DIC_VOD_NO_CONTENT_TITLE
    \    Should Not Be True    ${no_match}    No content found for selected provider ${providers_list[${i}]['title']}
    \    ${section_list}    Extract Value For Key    ${focused_tile}    id:shared-CollectionsBrowser    data    ${False}
    \    Should Not Be Empty    ${section_list['items']}    No content found for selected provider ${providers_list[${i}]['title']}
    \    I Press    BACK
    \    I wait for 1 second
    \    ${last_tile}    Evaluate    ${length}-1
    \    Exit For Loop If    ${last_tile}==${i}
    \    Move Focus To Direction And Assert    RIGHT    ${1}

Verify VOD Catalogue    #USED
    [Documentation]    This keyword checks that vod section details obtained from backend is relevant by
    ...    ensuring that those sections are displayed in UI without any errors and assets are displayed
    ...    inside the section
    Variable Should Exist    ${VOD_SECTION_DETAILS_DICTIONARY}    vod section details not saved in VOD_SECTION_DETAILS_DICTIONARY
    ${section_names}    Get Dictionary Keys    ${VOD_SECTION_DETAILS_DICTIONARY}
    ${sections}    Get Length    ${section_names}
    :FOR    ${i}    IN RANGE    0    ${sections}
    \    ${section_name}    Set Variable    ${section_names[${i}]}
    \    I open '${section_name}'
    \    I Press    DOWN
    \    Error popup is not shown
    \    ${asset_details}    Set Variable    ${VOD_SECTION_DETAILS_DICTIONARY['${section_names[${i}]}']}
    \    ${random_asset_details}    Run Keyword If    "${section_name}"=="Providers"
    ...    Get Random Element From Array    ${asset_details[${0}]}
    ...    ELSE    Get Random Element From Array    ${asset_details}
    \    ${asset_to_navigate}    Set Variable    ${random_asset_details['title']}
    \    I focus '${asset_to_navigate}' tile
    \    I Press    MENU
    \    I wait for 1 second

Navigate To A Random Asset In Second Level Screen Of Providers Section    #USED
    [Documentation]    This keyword navigates to any random asset in second level screen of providers section
    ...    based on information of vod sections from the backend saved in VOD_SECTION_DETAILS_DICTIONARY
    ...    Precondition: on Demand is opened
    [Arguments]    ${vod_section_details_dictionary}
    Dictionary Should Contain Key    ${vod_section_details_dictionary}    Providers    Providers Section is not present
    I open 'Providers'
    ${section_names}    Get Dictionary Keys    ${vod_section_details_dictionary['Providers']}
    ${section_name}    Get Random Element From Array    ${section_names}
    ${section_details}    Set Variable    ${vod_section_details_dictionary['Providers']['${section_name}']}
    Move Focus to Tile in Grid Page    ${section_name}    title
    I Press    OK
    Error popup is not shown
    ${asset_to_navigate}    Get Subscribed Non 4K Asset Title    ${section_details}
    I focus '${asset_to_navigate}' tile

Get Subscribed Non 4K Asset Title    #USED
    [Documentation]    This keyword gets title of an asset that is subscribed to and not in 4K Resolution
    ...    section_details contains the list of assets in the vod section.
    [Arguments]    ${section_details}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${is_items}    Run Keyword And Return Status    Dictionary Should Contain Key    ${section_details}    items
    ${details_to_process}    Run Keyword If    ${is_items}    Set Variable    ${section_details}
    ...    ELSE    Get Random Element From Array    ${section_details['collections']}
    ${length}    Get Length    ${details_to_process['items']}
    ${valid_assets}    Create List
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${asset_info}    I Get Details Of A VOD Asset With Given Crid Id    ${details_to_process['items'][${i}]['id']}
    ...    ${cpe_profile_id}
    \    ${resolution}    Extract Value For Key    ${asset_info}    ${EMPTY}    resolution    ${False}
    \    ${offers_list}    Extract Value For Key    ${asset_info}    ${EMPTY}    offers    ${False}
    \    ${offer_type}    Extract Value For Key    ${offers_list[${0}]}    ${EMPTY}    type    ${False}
    \    ${is_valid}    Set Variable If    "${resolution}"=="4K"    ${False}    "${offer_type}"=="Subscription"    ${True}    ${False}
    \    Run Keyword If    ${is_valid}    Append To List    ${valid_assets}    ${details_to_process['items'][${i}]['title']}
    Should Not Be Empty    ${valid_assets}    Subscribed non 4K asset not found
    ${vod_title_to_navigate}    Get Random Element From Array    ${valid_assets}
    [Return]    ${vod_title_to_navigate}

Rent A Specific VOD Instance Of An Asset    #USED
    [Documentation]    This keyword rents a VOD Instance of a specific VOD Asset
    ...    Precondition: VOD details page is opened.
    [Arguments]    ${vod_instances}
    ${length}    Get Length    ${vod_instances}
    ${instance_list}    Create List
    :FOR    ${i}    IN RANGE    0    ${length}
    \    Append To List    ${instance_list}    ${vod_instances[${i}]['resolution']}
    Remove Values From List    ${instance_list}    4K
    ${instance_to_rent}    Get Random Element From Array    ${instance_list}
    First Action Is Focused
    I Press    OK
    Select A Video Quality From Modal Popup    ${instance_to_rent}
    Pin Entry popup is shown
    I enter a valid pin ensuring the rental process succeeds
    Validate Asset is Playing in Player And Exit Playback

Select A Video Quality From Modal Popup    #USED
    [Documentation]    This keyword selects a particular video quality given by
    ...    instance_to_rent from the modal popup that lets choose between different instances of a VOD asset to rent from.
    [Arguments]    ${instance_to_rent}
    I expect page contains 'id:InteractiveModalPopup'
    ${ui_json}    Get Ui Json
    :FOR    ${i}    IN RANGE    0    ${DEFAULT_MAX_MODAL_BUTTONS}
    \    ${search_param}    Catenate    SEPARATOR=    id:interactiveModalButton     ${i}
    \    ${option_names}    Extract Value For Key    ${ui_json}    ${search_param}    textValue    ${False}
    \    @{resolution}    Split String    ${option_names}
    \    ${is_found}    Run Keyword And Return Status    Should Be Equal As Strings    ${resolution[${0}]}    ${instance_to_rent}
    \    Exit For Loop If    ${is_found}
    \    I Press    DOWN
    Should Be True    ${is_found}    Instance selection validation failed
    I Press    OK

Extract Recently Added Section Of On Demand CMM From Backend    #USED
    [Documentation]    This keyword fetches data of recently added section of on demand CMM from backend
    ${contextual_menu}    I Get Contextual VOD Assets
    ${cmm_collections}    Extract Value For Key    ${contextual_menu}    ${EMPTY}    collections
    ${length}    Get Length    ${cmm_collections}
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${is_recent}    Run Keyword And Return Status    Should Be Equal As Strings    ${cmm_collections[${i}]['title']}
    ...    Recently added
    \    Continue For Loop If    ${is_recent}==${False}
    \    Set Suite Variable    ${RECENTLY_ADDED_ITEMS}    ${cmm_collections[${i}]['items']}

Extract Recommended For You Section Of On Demand CMM From Backend    #USED
    [Documentation]    This keyword fetches data of recommended for you section of on demand CMM from backend
    ${contextual_menu}    I Get Contextual VOD Assets
    ${cmm_collections}    Extract Value For Key    ${contextual_menu}    ${EMPTY}    collections
    ${length}    Get Length    ${cmm_collections}
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${check_one}    Run Keyword And Return Status    Should Be Equal As Strings    ${cmm_collections[${i}]['title']}
    ...    Recommended for you
    \    ${check_two}    Run Keyword And Return Status    Should Be Equal As Strings    ${cmm_collections[${i}]['title']}
    ...    Recommendations for you
    \    ${is_recommended}    Set Variable If    ${check_one}    ${True}    ${check_two}
    \    Continue For Loop If    ${is_recommended}==${False}
    \    Set Suite Variable    ${RECOMMENDED_ITEMS}    ${cmm_collections[${i}]['items']}

Get Tenant Specific Name For Providers Section    #USED
    [Documentation]    This keyword returns tenant specific names for 'Providers' section
    [Arguments]    ${assert_failure}=${True}
    ${current_country_code}    get country code from stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    ${section_name}    Run Keyword If    '${current_country_code}' == 'NL'    Set Variable    Providers
    ...    ELSE IF    '${current_country_code}' == 'BE'    Set Variable    Zenders
    ...    ELSE IF    '${current_country_code}' == 'GB' or '${current_country_code}' == 'CL'    Set Variable    Channels
    ...    ELSE IF    '${current_country_code}' == 'AT'    Set Variable    Catch up TV
    ...    ELSE    Set Variable    ${None}
    Run Keyword If    ${assert_failure}
    ...    Should Not Be Equal    ${section_name}    ${None}    Tenant ${current_country_code} does not have Providers Section
    Set Suite Variable    ${PROVIDERS_SECTION_NAME}    ${section_name}
    [Return]    ${section_name}

I Select A Single Age Rated VOD Asset Title '${only_tvod}'    #USED
    [Documentation]    This Keyword Gets An Age Rated VOD Asset From VOD Service And
    ...    Sets Suite Variable '${AGE_RATED_MOVIE_TITLE}' With Selected Asset Title
    ${section_name}    ${vod_asset_list}    Find Age Rated VOD Assets Belonging To A VOD Section    ${only_tvod}
    ${age_rated_asset}    Get Random Element From Array    ${vod_asset_list}
    Should Not Be Empty    ${age_rated_asset['title']}    'Unable To Get Asset From Backend'
    Set Suite Variable    ${AGE_RATED_MOVIE_TITLE}    ${age_rated_asset['title']}

Navigate To Given VOD Series Asset And Focus Given Episode    #USED
    [Documentation]    This keyword navigates to a VOD Asset whose title is provided and moves focus to episode
    ...    according to details provided
    [Arguments]    ${section_name}    ${series_title}    ${selected_season}    ${seasons_in_series}    ${episode_picker_title}
    ...    ${series_title}    ${episodes_in_season}
    I open '${section_name}'
    I focus '${series_title}' tile
    I open VOD Detail Page
    I open episode picker
    Check If Season Selected Is '${selected_season}', Otherwise Navigate To It Using Maximum Action '${seasons_in_series}'
    I Focus Episode With Details    ${episode_picker_title}    ${series_title}    ${episodes_in_season}

Get Random Episode From VOD Series Details    #USED
    [Documentation]    This keyword retrieves details to navigate to random episdode title from a random season of a VOD series asset
    ...    whose basic details are given
    [Arguments]    ${series_details}
    ${episode_navigation_dictionary}    Create Dictionary
    ${series_field}    Is In Json    ${series_details}    ${EMPTY}    seriesId:.*    ${None}    ${True}
    ${series_crid_check}    Run Keyword If    ${series_field}    Extract Value For Key    ${series_details}    ${EMPTY}    seriesId
    ${series_crid}    Set Variable If    ${series_field}    ${series_crid_check}    ${series_details['id']}
    ${series_content_details}    Get Season And Episode List Of A Series VOD Asset From Backend    ${series_crid}
    ${season_details}    Get Random Element From Array    ${series_content_details}
    ${episode_details}    Get Random Element From Array    ${season_details['vodEpisodeDetails'][0]}
    ${seasons}    Get Length    ${series_content_details}
    ${episodes}    Get Length    ${season_details['vodEpisodeDetails'][0]}
    ${episode_list_title}    Set Variable   Ep${episode_details['episode']} - ${episode_details['title']}
    Set To Dictionary    ${episode_navigation_dictionary}    seriesTitle    ${series_details['title']}
    Set To Dictionary    ${episode_navigation_dictionary}    seasonNumber    ${episode_details['season']}
    Set To Dictionary    ${episode_navigation_dictionary}    episodePickerTitle    ${episode_list_title}
    Set To Dictionary    ${episode_navigation_dictionary}    seasonsInSeries    ${seasons}
    Set To Dictionary    ${episode_navigation_dictionary}    episodesInSeason    ${episodes}
    [Return]    ${episode_navigation_dictionary}


Get Season And Episode List Of A Series VOD Asset From Backend    #USED
    [Documentation]    This keyword fetches the season and episode details for a series VOD asset if the series
    ...    crid_id is provided
    [Arguments]    ${series_crid_id}
    ${series_details}    I Get Series VOD Details    ${series_crid_id}
    ${season_info}    Extract Value For Key    ${series_details}    ${EMPTY}    seasons
    ${series_details_list}    Create List
    :FOR    ${season}    IN    @{season_info}
    \    Log    ${season}
    \    ${dict}    Create Dictionary
    \    ${episode_list}    Create List
    \    ${episode_details}    I Get Series VOD Details    ${season['id']}
    \    ${episode_info}    Extract Value For Key    ${episode_details}    ${EMPTY}    episodes
    \    Append To List    ${episode_list}    ${episode_info}
    \    Set To Dictionary    ${dict}    vodSeasonId    ${season['id']}    vodSeasonTitle    ${season['title']}
    ...    vodEpisodeDetails    ${episode_list}
    \    Append To List    ${series_details_list}    ${dict}
    [Return]    ${series_details_list}

Get VOD Series Assets Belonging To A Section From Backend    #USED
    [Documentation]    This keyword retrieves preliminary information about all series assets present in
    ...    any one of the sections in On Demand
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Retrieve VOD Root Category Structure From Backend
    ${details_list}    Create List
    :FOR    ${section_name}    IN    @{VOD_SECTIONS_DICTIONARY.keys()}
    \    Log    ${section_name}
    \    Continue For Loop If  '''${section_name}''' == '''x'''
    \    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    SERIES    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all
    \    Continue For Loop If    not ${movies_details}
    \    Append To List    ${details_list}    ${movies_details}
    \    ${is_present}    Run Keyword And Return Status    Should Not Be Empty    ${movies_details}
    \    Exit For Loop If    ${is_present}
    Should Not Be Empty    ${movies_details}    Series assets not available in any of the sections
    [Return]    ${section_name}    ${movies_details}

Identify Promotional Tile And Get Detailscreen Title    #USED
    [Documentation]    This keyword identifies that thr given asset title is a prootional tile or not. If so, fetches
    ...    its title from /detailscreen response. Used in cases where title mismatch occurs with respect to vod catalogue
    [Arguments]    ${section_name}    ${asset_title}    ${asset_crid}
    ${is_mismatch}    Run Keyword And Return Status    Variable Should Exist    ${TITLE_MISMATCH_OCCURRENCE}
    Return From Keyword If    not ${is_mismatch}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${structure_json}    Get Vod Full Vod Structure
    ${response}    Get Vod Screen From Screen Title    ${structure_json}    ${section_name}    ${True}
    ${vodscreen_json}    Get Enclosing Json    ${response}    ${EMPTY}    title:${asset_title}    ${2}
    ${collection_layout}    Extract Value For Key    ${vodscreen_json}    ${EMPTY}    collectionLayout
    ${is_promo}    Run Keyword And Return Status    Should Be Equal As Strings    ${collection_layout}    PromotionCollection
    Return From Keyword If    not ${is_promo}
    ${asset_info}    I Get Details Of A VOD Asset With Given Crid Id    ${asset_crid}    ${cpe_profile_id}
    Set Suite Variable    ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${asset_info}
    Set Suite Variable    ${TILE_TITLE}    ${asset_info['title']}
    [Return]    ${asset_info}

#***************************************CPE PERFORMANCE*************************************************

Is Provider Collection Screen Shown
    [Documentation]  Keyword to verify if screen is for the selected Provider
    [Arguments]  ${provider_title}
    ${focused_node}    Get Ui Focused Elements
    ${providers_focused}    Extract Value For Key    ${focused_node}    id:shared-CollectionsBrowser    title
    Should be equal    ${provider_title}     ${providers_focused}    Provider Screen is not Shown

Navigate to unentitled TVOD asset in Section    #USED
    [Documentation]    This keyword attempts to navigate TVOD asset from the given VOD section
    ...    of the On Demand screen.
    [Arguments]    ${section_name}
    Get Root Id From Purchase Service
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Log    ${section_name}
    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all
    ${movie_title}    Get TVOD non-entitled asset title    ${movies_details}
    set test variable    ${RENTED_MOVIE_TITLE}    @{movie_title}[0]
#    I open '${section_name}'
    I press    DOWN
    I focus '${RENTED_MOVIE_TITLE}' tile


Move to Provider
    [Documentation]  This keyword navigates to the specified named tile in the present collection
    ...    Precondition: Already on the providers screen
    [Arguments]  ${title}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     : FOR    ${INDEX}    IN RANGE    1    50
     \    Get Ui Focused Elements
     \    ${current_tile_json}    Get From List    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${-1}
     \    ${current_tile_title}    Extract Value For Key    ${current_tile_json}    ${EMPTY}    title
     \    exit for loop if    "${current_tile_title}" == "${title}"
     \    I Press    RIGHT
     \    I wait for 2 seconds

Move to Provider IE
    [Documentation]  This keyword navigates to the specified named tile in the present collection
    ...    Precondition: Already on the providers screen
    [Arguments]  ${title}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     Get Ui Focused Elements
     @{tiles}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser    items
     : FOR    ${tile_json}    IN     @{tiles}
     \    ${current_tile_title}   get title from ordereddict  ${tile_json}
#     \    ${current_tile_json}    Get From List    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${-1}
#     \    ${current_tile_title}    Extract Value For Key    ${current_tile_json}    ${EMPTY}    title
     \    exit for loop if    "${current_tile_title}" == "${title}"
     \    I Press    DOWN
     \    I wait for 2 seconds

Move to Provider with data
    [Documentation]  This keyword navigates to the specified named tile in the present collection
    ...    Precondition: Already on the providers screen
    [Arguments]  ${title}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     Get Ui Focused Elements
     @{tiles}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser    data
     : FOR    ${tile_json}    IN     @{tiles}
     \    ${current_tile_title}   get title from ordereddict  ${tile_json}
#     \    ${current_tile_json}    Get From List    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${-1}
#     \    ${current_tile_title}    Extract Value For Key    ${current_tile_json}    ${EMPTY}    title
     \    exit for loop if    "${current_tile_title}" == "${title}"
     \    I Press    RIGHT
     \    I wait for 2 seconds

#*****************************CPE PERFORMANCE******************************************************
Get Details of a purchasable asset
    [Documentation]    This keyword attempts to get details TVOD asset
    [Arguments]    ${section_name}
    Get Root Id From Purchase Service
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Log    ${section_name}
    ${movies_details}    Get Content    ${LAB_CONF}    ${section_name}    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CUSTOMER_ID}    all
    ${movie_title}    Get TVOD non-entitled asset title    ${movies_details}
    set test variable    ${RENTED_MOVIE_TITLE}    ${movie_title}
    I open '${section_name}'
    I press    DOWN
    I focus '${RENTED_MOVIE_TITLE}' tile