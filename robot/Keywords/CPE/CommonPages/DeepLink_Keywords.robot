*** Settings ***
Documentation     UI DeepLink Navigation Keywords
Resource          ./DeepLink_Implementations.robot

*** Variables ***
&{DEEPLINK_SAVED_SECTIONS}    Recordings=recordings    Watchlist=watchlist    Continue Watching=continue-watching    Rented=rented

*** Keywords ***
I open FullScreen through DeepLink
    [Documentation]    Opens Fullscreen view via DeepLink
    Open View through DeepLink    /FullScreen

I open Channel Bar through DeepLink
    [Documentation]    Opens Channel bar via DeepLink
    Open View through DeepLink    /NowAndNext

I open Main Menu through DeepLink
    [Documentation]    Opens Main menu via DeepLink
    Open View through DeepLink    /MainMenu

I Open Search through DeepLink
    [Arguments]    ${text}=${EMPTY}
    [Documentation]    Opens the Search View via Deeplink. It can take an optional text argument to directly search
    ...    for something
    ${params}    Set Variable    {"literal": "${text}"}
    Open View through DeepLink    /Search    ${params}
    set test variable    ${SEARCH_QUERY}    ${text}

I open the Guide Menu through DeepLink
    [Documentation]    Opens Guide via DeepLink
    Open View through DeepLink    /Guide

I open the On Demand Menu through DeepLink
    [Documentation]    Opens the On Demand Menu via DeepLink
    Open View through DeepLink    /Vod

I open the Saved Menu through DeepLink
    [Documentation]    Opens the Saved Menu via DeepLink
    Open View through DeepLink    /Saved

I open the Apps Menu through DeepLink
    [Documentation]    Opens the Apps Menu via DeepLink
    Open View through DeepLink    /AppStore

I open the Settings Menu through DeepLink
    [Documentation]    Opens the Settings Menu via DeepLink
    Open View through DeepLink    /Settings

I Search for '${text}' through DeepLink
    [Documentation]    Opens the Search View via Deeplink and directly search for a text string
    I open Search through DeepLink    ${text}

I open the Rent On Demand Section through DeepLink
    [Documentation]    Opens the Rent On Demand section via DeepLink
    Open View through DeepLink    /Vod/rentScreen

I open the Movies On Demand Section through DeepLink
    [Documentation]    Opens the Movies On Demand section via DeepLink
    Open View through DeepLink    /TestTools/VodSection    {"sectionId":"crid:~~2F~~2Fschange.com~~2F2a17e23c-f729-49c7-8b6c-e3a07ce43668"}

I open the Adult On Demand Area through DeepLink
    [Documentation]    Opens the Adult (Passion/Erotik) On Demand Area via DeepLink.
    ...    Only available with NL or FR language setup.
    ...    Warning: it bypass the adult Pin code popup, so the tiles & titles are still protected
    ...    and popup will show up when opening a DP from a tile
    Open View through DeepLink    /Vod/adultRentScreen

I open the ${section} Section in Saved through DeepLink
    [Documentation]    Opens a Saved section via DeepLink. Available sections are:
    ...    Recordings, Watchlist, Continue Watching, and Rented
    Open View through DeepLink    /Saved/${DEEPLINK_SAVED_SECTIONS['${section}']}

I launch the ${app_name} application through DeepLink
    [Documentation]    Launch any application via DeepLink
    Open View through DeepLink    /App/${app_name}

I open a recording Detail Page through DeepLink
    [Documentation]    Open, via DeepLink, the Detail Page of the first Recording
    ...    found via application service
    @{recordings}    Get recording ID list from STB via AS
    Open Recording Details Page through DeepLink    ${recordings[0]}

I open a VOD asset Detail Page through DeepLink
    [Documentation]    Open, via DeepLink, the Detail Page of the first asset in the Discover screen.
    ...    Currently we can't use DeepLinking to access the Details Page of an asset directly, so a bit of regular
    ...    navigation is made in addition of DeepLink.
    ...    This is temporary until ONEMUI-21396 is implemented.
    I open the Movies On Demand Section through DeepLink
    Collection tiles are shown
    Generate OnDemand category dictionary
    I focus a VOD tile from On Demand
    I open VOD Detail Page
