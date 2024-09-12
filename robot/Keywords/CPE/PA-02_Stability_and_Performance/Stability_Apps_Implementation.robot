*** Settings ***
Documentation     Stability Apps keyword definitions

*** Variables ***
@{SUPPORTED_APPS}    YouTube    Vevo
@{SUPPORTED_LAUNCH_METHOD}    AppStore    Countries

*** Keywords ***
Query screenshot to check '${app_name}' app is launched
    [Documentation]    Verify if the specific application(${app_name}) is indeed launched. Currently only 'Youtube' app is supported.
    run keyword if    '${app_name}'!='YouTube'    fail test    App ${app_name} is not supported.
    ${is_launched}    is youtube launched    ${STB_SLOT}
    run keyword unless    ${is_launched}    fail test    Failed to launch ${app_name} app

Query screenshot via template to check '${app_name}' app is launched
    [Documentation]    Verify if the ${app_name} application is launched comparing the current screen
    ...    to the ${app_name}_launched.png image file.
    ${app_is_launched}    is template present on screen    ${STB_SLOT}    ${app_name}_launched
    should be true    ${app_is_launched}    Failed to launch the '${app_name}' app

Query screenshot to check '${app_name}' exit screen cancel option is highlighted
    [Documentation]    Verify if the specific application exit screen Cancel option is highlighted, and returns failure if not.
    ...    Currently only 'Youtube' app is supported.
    ${is_selected}    is youtube exit screen cancel highlighted    ${STB_SLOT}
    run keyword unless    ${is_selected}    fail test    Exit screen cancel option is not highlighted for ${app_name}.

Query screenshot to check '${app_name}' exit screen exit option is highlighted
    [Documentation]    Verify if the specific application exit screen Exit option is highlighted, and returns failure if not.
    ...    Currently only 'Youtube' app is supported.
    ${is_selected}    is youtube exit screen exit highlighted    ${STB_SLOT}
    run keyword unless    ${is_selected}    fail test    Exit screen exit option is not highlighted for ${app_name}.

Stability open '${app_name}' via 'AppStore'
    [Documentation]    Open specific application ${app_name} via the App Store section in Apps.
    ...    Currently only 'Youtube' app is supported.
    run keyword if    '${app_name}'!='YouTube'    fail test    Keyword "Stability open '${app_name}' via 'AppStore'" is not supported
    I Press    MENU
    I wait for 2 second
    repeat keyword    3 times    I press    LEFT
    I wait for 3 second
    get screenshot    ${STB_SLOT}
    # Apps highlighted
    I press    OK
    I wait for 3 second
    get screenshot    ${STB_SLOT}
    # Apps opened
    I press    RIGHT
    I wait for 4 second
    get screenshot    ${STB_SLOT}
    # Appstore highlighted
    I press    DOWN
    I wait for 2 second
    get screenshot    ${STB_SLOT}
    # TV & Video collection highlighted
    I press    OK
    I wait for 3 second
    get screenshot    ${STB_SLOT}
    # TV & Video collection opened. Application not highlighted
    repeat keyword    1 times    I press    RIGHT
    I wait for 3 second
    # Application highlighted
    I press    OK
    is '${app_name}' app launched
    I wait for 3 second

Stability open '${app_name}' via 'Countries'
    [Documentation]    Open specific application ${app_name} via the Countries section in Apps.
    ...    Currently only 'Vevo' app is supported.
    run keyword if    '${app_name}'!='Vevo'    fail test    Keyword "Stability open '${app_name}' via 'Countries'" is not supported
    I Press    MENU
    I wait for ${UI_LOAD_DELAY} ms
    User press LEFT for 3 times with delay of 1 seconds
    I wait for ${UI_LOAD_DELAY} ms
    I press    OK
    wait until keyword succeeds    5s    1s    Query screenshot to check the 'apps_screen_for_you_focused' template is present
    User press LEFT for 2 times with delay of 1 seconds
    wait until keyword succeeds    5s    1s    Query screenshot to check the 'apps_screen_countries_focused' template is present
    I press    OK
    I wait for ${UI_LOAD_DELAY} ms
    User press RIGHT for 4 times with delay of 1 seconds
    wait until keyword succeeds    5s    1s    Query screenshot to check the 'gb_editorial_focused' template is present
    I press    OK
    I wait for ${UI_LOAD_DELAY} ms
    User press RIGHT for 7 times with delay of 1 seconds
    wait until keyword succeeds    5s    1s    Query screenshot to check the 'vevo_app_focused' template is present
    I press    OK
    I wait for ${UI_LOAD_DELAY} ms
    wait until keyword succeeds    20s    1s    Query screenshot via template to check '${app_name}' app is launched

Stability exit '${app_name}' with '${key}' key
    [Documentation]    Exit ${app_name} application using the specified ${key} key press. Currently only 'Youtube' app is supported.
    run keyword if    '${key}'!='BACK'    run keywords    I press    ${key}
    ...    AND    I wait for 2 second
    ...    AND    Conditional Channel Content Check
    ...    AND    return from keyword
    wait until keyword succeeds    10s    1s    Stability press BACK key in '${app_name}' App to check if Exit Screen Cancel Option is selected
    I Press    RIGHT
    wait until keyword succeeds    10s    1s    Query screenshot to check '${app_name}' exit screen exit option is highlighted
    wait until keyword succeeds    3s    1s    I Press    OK
    I wait for 5 second
    ${launch_status}    run keyword and return status    is '${app_name}' app launched
    ${exit_screen_1}    run keyword and return status    Query screenshot to check '${app_name}' exit screen cancel option is highlighted
    ${exit_screen_2}    run keyword and return status    Query screenshot to check '${app_name}' exit screen exit option is highlighted
    Should not be true    ${launch_status} or ${exit_screen_1} or ${exit_screen_2}    App ${app_name} did not exit properly via '${key}' key.

Stability press BACK key in '${app_name}' App to check if Exit Screen Cancel Option is selected
    [Documentation]    Exit ${app_name} application using the specified BACK key.
    ...    Currently only 'Youtube' app is supported.
    wait until keyword succeeds    10s    1s    I Press    BACK
    wait until keyword succeeds    2s    100ms    Query screenshot to check '${app_name}' exit screen cancel option is highlighted

Launch stability '${app_name}' app via '${launch}' while noting any failure encountered
    [Documentation]    Launch ${app_name} app and return failure if any failure encountered. Currently only 'Youtube' app is supported.
    ${is_app_supported}    Evaluate    '${app_name}' in ${SUPPORTED_APPS}
    ${is_launch_supported}    Evaluate    '${launch}' in ${SUPPORTED_LAUNCH_METHOD}
    should be true    ${is_app_supported} and ${is_launch_supported}    Keyword "Launch stability '${app_name}' app via '${launch}' while noting any failure encountered" is not supported
    ${launch_status}    run keyword and return status    Stability open '${app_name}' via '${launch}'
    ${exit_status}    run keyword if    ${launch_status}    run keyword and return status    Stability exit '${app_name}' with 'LIVETV' key
    Stability update current iteration report    ${launch_status} and ${exit_status}
    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'

Stability attempt to playback a '${app_name}' asset
    [Documentation]    Attempt to playback the '${app_name}' asset, assuming the '${app_name}' is already launched.
    ...    Currently only apps in the ${SUPPORTED_APPS} list are supported.
    ${is_app_supported}    Evaluate    '${app_name}' in ${SUPPORTED_APPS}
    should be true    ${is_app_supported}    App ${app_name} is not supported.
    run keyword    Stability play a '${app_name}' asset

Stability play a 'YouTube' asset
    [Documentation]    Attempt to playback an asset from 'YouTube' app, assuming it is already launched and
    ...    with RIGHT key press, a valid asset gets focused.
    I press    RIGHT
    I wait for 2 second
    I press    OK
    wait until keyword succeeds    20s    1s    content available

Stability play a 'Vevo' asset
    [Documentation]    Attempt to playback an asset from 'Vevo' app, assuming it is already launched, the welcome
    ...    screen needs to be dismissed and an asset is already focused after that.
    I press    OK
    wait until keyword succeeds    5s    1s    Query screenshot to check the 'vevo_playlists' template is present
    I press    OK
    I wait for 5 seconds
    wait until keyword succeeds    10s    1s    content available

Is '${app_name}' app launched
    [Documentation]    Attempt to detect the specific application(${app_name}) is indeed launched. Currently only 'YouTube' app is supported.
    Run keyword if    '${app_name}'!='YouTube'    fail test    Keyword 'Is '${app_name}' app launched' not support for '${app_name}' app
    Wait until keyword succeeds    20s    300 ms    Query screenshot to check '${app_name}' app is launched

Query screenshot to check the '${template_name}' template is present
    [Documentation]    Verify if the template image file with ${template_name} name is present comparing it to the current screen.
    ${template_is_shown}    is template present on screen    ${STB_SLOT}    ${template_name}
    should be true    ${template_is_shown}    Current screen doesn't contain the element shown in template '${template_name}.png'
