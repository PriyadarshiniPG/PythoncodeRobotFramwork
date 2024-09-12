*** Settings ***
Documentation     Implementation Keywords for WatchlistService
Library           Libraries.MicroServices.WatchlistService

*** Keywords ***
Get Watchlist ID
    [Documentation]    This keyword gets watchlist content via application service
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${watchlist_content}    Get Watchlist Content    ${profile}    ${CUSTOMER_ID}    ${OSD_LANGUAGE}
    ...   ${CPE_ID}
    [Return]    &{watchlist_content}[watchlistId]

Add VOD Content To Watchlist
    [Documentation]    Add the given VOD content to the watchlist
    [Arguments]    ${crid}    ${tile}
    ${Watchlist_ID}    Get Watchlist ID
    Add VOD Watchlist Event   ${Watchlist_ID}    ${CUSTOMER_ID}    ${crid}    ${tile}