*** Settings ***
Documentation     Show Page keywords
Resource          ../Common/Common.robot

*** Keywords ***
Show Page is shown
    [Documentation]  The header is identical to the Details Page but the primary metadata differs so this can be checked
    ...    as it's specific to the Show page.
    Details Page Header is shown
    wait until keyword succeeds    3 times    1 sec    I expect page element 'id:detailedInfoprimaryMetadata' contains 'textKey:DIC_GENERIC_AMOUNT_SEASON*' using regular expressions
