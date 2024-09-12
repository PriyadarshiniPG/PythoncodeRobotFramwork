*** Settings ***
Documentation     Keywords concerning the JSON handler and JSON retrieval from the STB
Resource          ../Common/Common.robot
Library           Collections
#Library           Libraries.Stb.DegradedMode
Library           Libraries.UiCheck.JsonUiHandler

*** Variables ***
${JSON_MAX_RETRIES}    4times
${JSON_RETRY_INTERVAL}    0.5s

*** Keywords ***
Layer is empty
    [Arguments]    ${layer_name}    ${use_last_fetched}=False
    [Documentation]    Check if a UI layer (HEADER_LAYER, ERROR_POPUP_LAYER, ...) is empty
    ${json_object}    Run keyword If    ${use_last_fetched}    Set Variable    ${LAST_FETCHED_JSON_OBJECT}
    ...    ELSE    Get Ui Json
    ${layer}    Set Variable    ${json_object['${layer_name}']}
    ${layer_length}    Get Length    ${layer}
    Should be True    ${layer_length} == 0    ${layer_name} is not empty: ${layer}

Layer is not empty
    [Arguments]    ${layer_name}    ${use_last_fetched}=False
    [Documentation]    Check if a UI layer (HEADER_LAYER, ERROR_POPUP_LAYER, ...) is not empty
    ${json_object}    Run keyword If    ${use_last_fetched}    Set Variable    ${LAST_FETCHED_JSON_OBJECT}
    ...    ELSE    Get Ui Json
    ${layer}    Set Variable    ${json_object['${layer_name}']}
    ${layer_length}    Get Length    ${layer}
    Should not be True    ${layer_length} == 0    ${layer_name} is empty: ${layer}

Enable JSON Ui Handler via Application Services    #USED
    [Documentation]    Enable JSON handler via a call to the Application Services.
    ...    Reference: https://wikiprojects.upc.biz/display/CATT/How+to+setup+TEST_TOOLS
    ...    This is the only working method after the implementation of ONEMUI-14170
    ${data}    Convert To Boolean    True
    Wait Until Keyword Succeeds    3x    2s    Set Application Services Setting    cpe.uiTestTools    ${data}

Disable JSON Ui Handler via Application Services    #USED
    [Documentation]    Enable JSON handler via a call to the Application Services.
    ...    Reference: https://wikiprojects.upc.biz/display/CATT/How+to+setup+TEST_TOOLS
    ...    This is the only working method after the implementation of ONEMUI-14170
    ${data}    Convert To Boolean    False
    Wait Until Keyword Succeeds    3x    2s    Set Application Services Setting    cpe.uiTestTools    ${data}

Change JSON Setting via Application Services    #USED
    [Arguments]    ${flag}
    [Documentation]    This keyword changes the cpe.uiTestTools flag via APP services
    Run Keyword if    '${flag}' != 'True'    Disable JSON Ui Handler via Application Services
    ...    ELSE    Enable JSON Ui Handler via Application Services

I Want To Enable Json Handler Function
    [Documentation]    Keyword to enable JSON handler. Only one method is supported
    ...    after the implementation of ONEMUI-14170; this is it.
    ...    Steps:
    ...    1. check JSON enabler value
    ...    2. eventually enable JSON handler via application services
    ...    3. try to Get UI Json
    ...    if the last step fails it means there is a misbehaviour of the UI
    ...    (Test tools are enabled but json cannot be retrieved)
    ${are_test_tools_enabled}    get application service setting    cpe.uiTestTools
    ${json_status}    ${value}    Run Keyword And Ignore Error    Should Be True    ${are_test_tools_enabled}    Test tools are not enabled
    Run Keyword Unless    '${json_status}' == 'PASS'    Enable JSON Ui Handler via Application Services
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Get Ui Json

I expect page contains '${page_content}'    #USED
    [Documentation]    This keyword asserts item ${page_content} is present in retrieved json
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    ${page_content}
    Should Be True    ${result}    Item '${page_content}' was not found

I expect focused elements contains '${page_content}'
    [Documentation]    This keyword asserts item ${page_content} is present in focused elements
    Log    I expect focused elements contains '${page_content}'
    ${json_object}    Get Ui Focused Elements
    ${result}    Is In Json    ${json_object}    ${EMPTY}    ${page_content}
    Should Be True    ${result}    Item '${page_content}' was not found

I expect page element '${page_item}' contains '${page_content}'     #USED
    [Documentation]    This keyword asserts item ${page_content} is present in item ${page_item}
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${page_item}    ${page_content}
    Should Be True    ${result}    Item '${page_content}' was not found in '${page_item}'

I expect page element '${page_item}' has text color '${text_color}'
    [Documentation]    This keyword asserts textStyle color ${text_color} is present in item ${page_item}
    ${json_object}    Get Ui Json
    ${textStyle}    Extract Value For Key    ${json_object}    ${page_item}    textStyle
    ${node_text_color}    Extract value for key    ${textStyle}    ${EMPTY}    color
    Should Be Equal    ${node_text_color}    ${text_color}    Item '${page_item}' has textcolor '${node_text_color}' instead of '${text_color}'

I expect page element '${page_item}' has text color '${text_color}' using regular expressions
    [Documentation]    This keyword asserts textStyle color ${text_color} is present in item ${page_item}
    ${json_object}    Get Ui Json
    ${textStyle}    Extract Value For Key    ${json_object}    ${page_item}    textStyle    ${True}
    ${node_text_color}    Extract value for key    ${textStyle}    ${EMPTY}    color
    Should Be Equal    ${node_text_color}    ${text_color}    Item '${page_item}' has textcolor '${node_text_color}' instead of '${text_color}'

I expect focused element '${page_item}' contains '${page_content}'
    [Documentation]    This keyword asserts item ${page_content} is present in focused item ${page_item}
    ${json_object}    Get Ui Focused Elements
    ${result}    Is In Json    ${json_object}    ${page_item}    ${page_content}
    Should Be True    ${result}    Item '${page_content}' was not found in '${page_item}'

I retrieve value for key '${item_key}' in element '${page_item}'    #USED
    [Documentation]    This keyword retrieves value for key ${item_key} in item ${page_item}
    ${json_object}    Get Ui Json
    ${result}    Extract Value For Key    ${json_object}    ${page_item}    ${item_key}
    [Return]    ${result}

I retrieve value for key '${item_key}' in focused element '${page_item}'    #USED
    [Documentation]    This keyword retrieves value for key ${item_key} in focused item ${page_item}
    ${json_object}    Get Ui Focused Elements
    ${result}    Extract Value For Key    ${json_object}    ${page_item}    ${item_key}
    [Return]    ${result}

I do not expect page element '${page_item}' contains '${page_content}'
    [Documentation]    This keyword asserts item ${page_content} is not present in item ${page_item}
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${page_item}    ${page_content}
    Should Not Be True    ${result}    Item '${page_content}' was found in '${page_item}'

I retrieve json ancestor of level '${ancestor_level:\d+}' for element '${page_content}'     #USED
    [Documentation]    This keyword retrieves ancestor json node of given level for element identified by ${page_content}
    ${json_object}    Get Ui Json
    ${ancestor_level}    Convert To Integer    ${ancestor_level}
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    ${page_content}    ${ancestor_level}
    [Return]    ${ancestor}

I retrieve json ancestor of level '${ancestor_level:\d+}' in element '${page_item}' for element '${page_content}'
    [Documentation]    This keyword retrieves ancestor json node of given level for element identified by ${page_content} supposedly present in ${page_item}
    ${json_object}    Get Ui Json
    ${ancestor_level}    Convert To Integer    ${ancestor_level}
    ${ancestor}    Get Enclosing Json    ${json_object}    ${page_item}    ${page_content}    ${ancestor_level}
    [Return]    ${ancestor}

I do not expect page contains '${page_content}'     #USED
    [Documentation]    Asserts given element does not exist in retrieved json
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    ${page_content}
    Should Not Be True    ${result}    Item '${page_content}' was found

I expect page contains '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    ${page_content}    ${EMPTY}    ${True}
    Should Be True    ${result}    Item '${page_content}' was not found

I expect focused elements contains '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Focused Elements
    ${result}    Is In Json    ${json_object}    ${EMPTY}    ${page_content}    ${EMPTY}    ${True}
    Should Be True    ${result}    Item '${page_content}' was not found

I expect page element '${page_item}' contains '${page_content}' using regular expressions    #USED
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_item} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${page_item}    ${page_content}    ${EMPTY}    ${True}
    Should Be True    ${result}    Item '${page_content}' was not found in '${page_item}'

I expect focused element '${page_item}' contains '${page_content}' using regular expressions
    [Documentation]    This keyword does the validation of focused element with regular expressions
    ...    example id:^\\d+$
    ${json_object}    Get Ui Focused Elements
    ${result}    Is In Json    ${json_object}    ${page_item}    ${page_content}    ${EMPTY}    ${True}
    Should Be True    ${result}    Item '${page_content}' was not found in '${page_item}'

I retrieve value for key '${item_key}' in element '${page_item}' using regular expressions    #USED
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_item} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${result}    Extract Value For Key    ${json_object}    ${page_item}    ${item_key}    ${True}
    [Return]    ${result}

I retrieve value for key '${item_key}' in focused element '${page_item}' using regular expressions
    [Documentation]    This keyword looks for the property of a focused element matching with a regular expression
    ...    Example: I retrieve value for key 'textKey' in element 'id:SectionNavigationListItem-.*'
    ...    ${page_item} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${focused_elements}    Get Ui Focused Elements
    ${result}    Extract Value For Key    ${focused_elements}    ${page_item}    ${item_key}    ${True}
    [Return]    ${result}

I do not expect page element '${page_item}' contains '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_item} and ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${page_item}    ${page_content}    ${EMPTY}    ${True}
    Should Not Be True    ${result}    Item '${page_content}' was found in '${page_item}'

I retrieve json ancestor of level '${ancestor_level:\d+}' for element '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${ancestor_level}    Convert To Integer    ${ancestor_level}
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    ${page_content}    ${ancestor_level}    ${EMPTY}
    ...    ${True}
    [Return]    ${ancestor}

I retrieve json ancestor of level '${ancestor_level:\d+}' for focused element '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Focused Elements
    ${ancestor_level}    Convert To Integer    ${ancestor_level}
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    ${page_content}    ${ancestor_level}    ${EMPTY}
    ...    ${True}
    [Return]    ${ancestor}

I retrieve json ancestor of level '${ancestor_level:\d+}' in element '${page_item}' for element '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_item} and ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${ancestor_level}    Convert To Integer    ${ancestor_level}
    ${ancestor}    Get Enclosing Json    ${json_object}    ${page_item}    ${page_content}    ${ancestor_level}    ${EMPTY}
    ...    ${True}
    [Return]    ${ancestor}

I do not expect page contains '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    ${page_content}    ${EMPTY}    ${True}
    Should Not Be True    ${result}    Item '${page_content}' was found

I do not expect focused elements contain '${page_content}' using regular expressions
    [Documentation]    This keyword does the same as the original one without regular expressions
    ...    ${page_content} should look like key:RE_PATTERN
    ...    example id:^\\d+$
    Get Ui Focused Elements
    ${result}    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${EMPTY}    ${page_content}    ${EMPTY}    ${True}
    Should Not Be True    ${result}    Item '${page_content}' was found

Focus Changed
    [Arguments]    ${focused_elements}
    [Documentation]    Check if Focused elements changed from the ones provided in argument and returns the new ones
    ${new_focused_elements}    Get Ui Focused Elements
    ${has_changed}    check if jsons are different    ${focused_elements}    ${new_focused_elements}
    Should be true    ${has_changed}    Item ${new_focused_elements} is not different than ${focused_elements}
    [Return]    ${new_focused_elements}

Get Ui Json    #USED
    [Documentation]    Keyword for getting UI with v2 api version, this is default endpoint for getting json
    ${start}  robot.libraries.DateTime.Get Current Date
    ${ret}    get ui json via tt    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    log    ${ret}
    ${stop}   robot.libraries.DateTime.Get Current Date
    ${diff}   robot.libraries.DateTime.Subtract Date From Date     ${stop}     ${start}
    Set Suite Variable    ${LAST_FETCHED_JSON_OBJECT}    ${ret}
    Set Suite Variable    ${LAST_HTTP_TIME}    ${diff}
    [Return]    ${ret}

Get Ui Json V1
    [Documentation]    Keyword for getting UI with old method /state
    ${ret}    get ui json via tt    ${STB_IP}    ${CPE_ID}    version=1    xap=${XAP}
    [Return]    ${ret}

Get Ui Focused Elements
    [Documentation]    Keyword for getting UI focused elements only in JSON
    ${start}  robot.libraries.DateTime.Get Current Date
    Log    Get Ui Focused Elements
    ${ret}    get ui json focused elements via tt    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Log    lib: JsonUiHandler: get ui json focused elements via tt
    Log    ${ret}
    ${stop}   robot.libraries.DateTime.Get Current Date
    ${diff}   robot.libraries.DateTime.Subtract Date From Date     ${stop}     ${start}
    Set Suite Variable    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${ret}
    Set Suite Variable    ${LAST_HTTP_TIME}    ${diff}
    [Return]    ${ret}

Set ${key} Ui Config to ${value}
    [Documentation]    Keyword for setting UI Config
    ${ret}    set ui config via tt    ${STB_IP}    ${CPE_ID}    ${key}    ${value}    xap=${XAP}
    [Return]    ${ret}

Get Ui Browser Processes
    [Documentation]    Keyword for getting UI processes state
    ${ret}    Get Data Via Testtools    ${STB_IP}    ${CPE_ID}    /process?filter=runId:browser    ${XAP}
    [Return]    ${ret}

Reset Recently Used Apps    #USED
    [Documentation]    Keyword for reset of the recently used app list
    ${ret}    reset recently used apps via tt    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${ret}

Set Recently Used Apps    #USED
    [Arguments]    ${app_list}
    [Documentation]    Keyword to set of the recently used app list with app ids seperated by comas
    ${ret}    set recently used apps via tt    ${STB_IP}    ${CPE_ID}    ${app_list}    xap=${XAP}
    [Return]    ${ret}

Assert focused elements changed
    [Arguments]    ${old_json}
    [Documentation]    This keyword asserts the focused elements changed
    ${new_json}    Get Ui Focused Elements
    ${are_different}    check if jsons are different    ${old_json}    ${new_json}
    Should Be True    ${are_different}    Item ${new_json} is not different than ${old_json}

Get Ui App Processes
    [Documentation]    Keyword for getting UI Application processes state
    ${ret}    Get Data Via Testtools    ${STB_IP}    ${CPE_ID}    /process?isApp    ${XAP}
    [Return]    ${ret}

Assert json node changed
    [Arguments]    ${old_json_node}    ${node_id}    ${property}
    [Documentation]    This keyword asserts content changed for property ${property} in json node with id ${node_id}
    ${json_object}    Get Ui Json
    ${new_json_node}    Extract Value For Key    ${json_object}    id:${node_id}    ${property}
    Set Suite Variable    ${LAST_FETCHED_JSON_NODE}    ${new_json_node}
    ${are_different}    check if jsons are different    ${old_json_node}    ${new_json_node}
    Should Be True    ${are_different}    JSON node content has not changed

Get Player Json
    [Documentation]    Keyword for getting current player Json
    ${ret}    get player json via tt    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Set Suite Variable    ${LAST_FETCHED_PLAYER_JSON}    ${ret}
    [Return]    ${ret}