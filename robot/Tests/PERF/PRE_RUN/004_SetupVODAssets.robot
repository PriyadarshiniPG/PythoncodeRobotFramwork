*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        Setup_VODAssets    SETUP
Resource          ./Settings.robot

#Last Modified    Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Tags]    TOOL_CPE
    [Setup]    Default First TestCase Setup
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${vod_structure}    Get Vod Full Vod Structure
    ${vod_screens}    Set Variable     ${vod_structure['screens']}
    # Handle all the generic sections
    :FOR    ${sceen_data}    IN     @{vod_screens}
    \     Log    ${sceen_data}
    \     ${section_title}   set variable  &{sceen_data}[title]
    \     ${section_crid}   set variable  &{sceen_data}[id]
    \     ${generic_name}    Get Action For Section Navigation      VOD    ${section_title}
    # Handle providers section based on country
    \     run keyword if   '${COUNTRY}' == 'ch' and '${generic_name}' == 'PROVIDERS'
    \     ...   Set PROVIDER Data For CH     ${vod_structure}   ${section_title}
#    \     run keyword if   '${COUNTRY}' == 'nl' and '${generic_name}' == 'PROVIDERS'
#    \     ...   Set PROVIDER Data For NL     ${vod_structure}   ${section_crid}
    \     run keyword if   '${COUNTRY}' == 'be' and '${generic_name}' == 'PROVIDERS'
    \     ...   Set PROVIDER Data For BE     ${vod_structure}   ${section_crid}
    \     run keyword if   '${COUNTRY}' == 'pl' and '${generic_name}' == 'PROVIDERS'
    \     ...   Set PROVIDER Data For PL     ${vod_structure}   ${section_crid}
    \     run keyword if   '${COUNTRY}' == 'gb' and '${generic_name}' == 'PROVIDERS'
    \     ...   Set PROVIDER Data For UK     ${vod_structure}   ${section_crid}
    \     run keyword if   '${COUNTRY}' == 'ie' and '${generic_name}' == 'PROVIDERS'
    \     ...   Set PROVIDER Data For IE     ${vod_structure}   ${section_title}   ${generic_name}
    \     continue for loop if   '${generic_name}' == 'PROVIDERS' or '${generic_name}' == 'RENT'
    \     ${response}    Get Vod Screen From Screen Title    ${vod_structure}    ${section_title}    ${True}
    \     ${collections}   set variable    &{response}[collections]
    \     ${collection_index}   set variable if   '${generic_name}' == 'SERIES'   -2    -2
    \     ${collection_data}    set variable    @{collections}[${collection_index}]
    \     ${collection_title}   set variable    &{collection_data}[title]
    \     ${collection_items}   set variable    &{collection_data}[items]
    \     Log    ${collection_items}
    \     ${asset_data}  set variable    @{collection_items}[1]
    \     ${asset_title}  set variable    &{asset_data}[title]
    \     Log to console    ${generic_name}: ${collection_title},${asset_title}
    \     Update Test Config    VOD_${generic_name}_COLLECTION    ${collection_title}
    \     Update Test Config    VOD_${generic_name}_ASSET    ${asset_title}


*** Keywords ***
Set PROVIDER Data For CH
    [Documentation]      Set the VOD Details required for PROVIDER section in NL
    [Arguments]    ${vod_structure}   ${section_title}
    ${response}    Get Vod Screen From Screen Title    ${vod_structure}    ${section_title}    ${True}
    ${collections}   set variable    &{response}[collections]
    ${collection_index}   set variable    -1
    ${collection_data}    set variable    @{collections}[${collection_index}]
    ${collection_title}   set variable    &{collection_data}[title]
    ${collection_items}   set variable    &{collection_data}[items]
    Log    ${collection_items}
    ${asset_data}  set variable    @{collection_items}[0]
    ${asset_title}  set variable    &{asset_data}[title]
    Log to console    PROVIDER: ${collection_title}, ${asset_title}
    Update Test Config    VOD_PROVIDERS_COLLECTION    ${collection_title}
    Update Test Config    VOD_PROVIDERS_ASSET    ${asset_title}

Set PROVIDER Data For NL
    [Documentation]      Set the VOD Details required for PROVIDER section in NL
    [Arguments]    ${vod_structure}   ${section_crid}
    ${section_response}   Get VOD Tile Screen From CRID     ${section_crid}
    ${items}   set variable   &{section_response}[items]
    ${provider_data}   set variable   @{items}[1]
    ${provider_crid}   set variable   &{provider_data}[id]
    ${provider_title}   set variable   &{provider_data}[title]
    ${provider_vod_structure}    Get VOD Tile Structure From CRID    ${provider_crid}
    ${response}    Get Vod Screen From Screen Title    ${provider_vod_structure}    ${provider_title}    ${True}
    ${collections}   set variable    &{response}[collections]
    ${collection_data}    set variable    @{collections}[-1]
    ${collection_title}   set variable    &{collection_data}[title]
    ${collection_items}   set variable    &{collection_data}[items]
    ${asset_data}  set variable    @{collection_items}[0]
    ${asset_title}  set variable    &{asset_data}[title]
    Update Test Config    VOD_PROVIDERS_PROVIDER    ${provider_title}
    Update Test Config    VOD_PROVIDERS_COLLECTION    ${collection_title}
    Update Test Config    VOD_PROVIDERS_ASSET    ${asset_title}
    Log to console    PROVIDER-${provider_title}: ${collection_title},${asset_title}

Set PROVIDER Data For BE
    [Documentation]      Set the VOD Details required for PROVIDER section in NL
    [Arguments]    ${vod_structure}   ${section_crid}
    ${section_response}   Get VOD Tile Screen From CRID     ${section_crid}
    ${items}   set variable   &{section_response}[items]
    ${provider_data}   set variable   @{items}[0]
    ${provider_crid}   set variable   &{provider_data}[id]
    ${provider_title}   set variable   &{provider_data}[title]
    ${provider_vod_structure}    Get VOD Tile Structure From CRID    ${provider_crid}
    @{sections}   set variable    @{provider_vod_structure['screens']}
    ${section}    set variable    @{sections}[0]
    ${section_title} =	Convert To Upper Case	${section['title']}
    ${response}    Get Vod Screen From Screen Title    ${provider_vod_structure}    ${section_title}    ${True}
    ${collections}   set variable    &{response}[collections]
    ${collection_data}    set variable    @{collections}[-1]
    ${collection_title}   set variable    &{collection_data}[title]
    ${collection_items}   set variable    &{collection_data}[items]
    ${asset_data}  set variable    @{collection_items}[0]
    ${asset_title}  set variable    &{asset_data}[title]
    Update Test Config    VOD_PROVIDERS_PROVIDER    ${provider_title}
    Update Test Config    VOD_PROVIDERS_COLLECTION    ${collection_title}
    Update Test Config    VOD_PROVIDERS_ASSET    ${asset_title}
    Update Test Config    VOD_PROVIDERS_PROVIDER_SECTION    ${section_title}
    Log to console    PROVIDER- ${provider_title}: ${section_title} - ${collection_title},${asset_title}

Set PROVIDER Data For PL
    [Documentation]      Set the VOD Details required for PROVIDER section in PL
    [Arguments]    ${vod_structure}   ${section_crid}
    ${section_response}   Get VOD Tile Screen From CRID     ${section_crid}
    ${items}   set variable   &{section_response}[items]
    ${provider_data}   set variable   @{items}[1]
    ${provider_crid}   set variable   &{provider_data}[id]
    ${provider_title}   set variable   &{provider_data}[title]
    ${provider_vod_structure}    Get VOD Tile Structure From CRID    ${provider_crid}
    ${response}    Get Vod Screen From Screen Title    ${provider_vod_structure}    ${provider_title}    ${True}
    ${collections}   set variable    &{response}[collections]
    ${collection_data}    set variable    @{collections}[-1]
    ${collection_title}   set variable    &{collection_data}[title]
    ${collection_items}   set variable    &{collection_data}[items]
    ${asset_data}  set variable    @{collection_items}[1]
    ${asset_title}  set variable    &{asset_data}[title]
    Update Test Config    VOD_PROVIDERS_PROVIDER    ${provider_title}
    Update Test Config    VOD_PROVIDERS_COLLECTION    ${collection_title}
    Update Test Config    VOD_PROVIDERS_ASSET    ${asset_title}
    Log to console    PROVIDER-${provider_title}: ${collection_title},${asset_title}

Set PROVIDER Data For UK
    [Documentation]      Set the VOD Details required for PROVIDER section in NL
    [Arguments]    ${vod_structure}   ${section_crid}
    ${section_response}   Get VOD Tile Screen From CRID     ${section_crid}
    ${items}   set variable   &{section_response}[items]
    ${provider_data}   set variable   @{items}[0]
    ${provider_crid}   set variable   &{provider_data}[id]
    ${provider_title}   set variable   &{provider_data}[title]
    ${provider_vod_grid_collection}    Get VOD Gridscreen From CRID    ${provider_crid}
    ${items}   set variable   &{provider_vod_grid_collection}[items]
    ${asset_data}   set variable   @{items}[1]
    ${asset_crid}   set variable   &{asset_data}[id]
    ${asset_title}   set variable   &{asset_data}[title]
    Log to console    PROVIDERS: ${provider_title},${asset_title}
    Update Test Config    VOD_PROVIDERS_PROVIDER    ${provider_title}
    Update Test Config    VOD_PROVIDERS_ASSET    ${asset_title}

Set PROVIDER Data For IE
    [Documentation]      Set the VOD Details required for PROVIDER section in NL
    [Arguments]    ${vod_structure}    ${section_title}    ${generic_name}
    ${response}    Get Vod Screen From Screen Title    ${vod_structure}    ${section_title}    ${True}
    ${collections}   set variable    &{response}[collections]
    ${collection_index}   set variable if   '${generic_name}' == 'SERIES'   -2    -4
    ${collection_data}    set variable    @{collections}[${collection_index}]
    ${collection_title}   set variable    &{collection_data}[title]
    ${collection_items}   set variable    &{collection_data}[items]
    Log    ${collection_items}
    ${asset_data}  set variable    @{collection_items}[0]
    ${asset_title}  set variable    &{asset_data}[title]
    Log to console    ${generic_name}: ${collection_title},${asset_title}
    Update Test Config    VOD_${generic_name}_COLLECTION    ${collection_title}
    Update Test Config    VOD_${generic_name}_ASSET    ${asset_title}

Get VOD Tile Screen From CRID
    [Documentation]    Gets the tile screen for the given crid
    [Arguments]    ${section_crid}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${section_response}  Get Vod tilescreen   ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}
    ...   ${customerid}   ${cpe_profile_id}   ${ROOT_ID}   ${section_crid}   ${True}
    [Return]   ${section_response.json()}

Get VOD Tile Structure From CRID
    [Documentation]    Gets the tile screen for the given crid
    [Arguments]    ${CRID}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${vod_structure}   Get Vod Structure by crid    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}
    ...   ${customerid}   ${cpe_profile_id}   ${ROOT_ID}   ${CRID}
    Log    ${vod_structure}
    [Return]     ${vod_structure.json()}

Get VOD Gridscreen From CRID
    [Documentation]    Gets the tile screen for the given crid
    [Arguments]    ${CRID}
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${grid_response}    Get Vod Gridscreen    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${customerid}    ${cpe_profile_id}    ${ROOT_ID}
    ...    ${CRID}    False
    [Return]     ${grid_response.json()}

