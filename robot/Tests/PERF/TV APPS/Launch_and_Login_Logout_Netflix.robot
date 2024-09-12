*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CCNNetflix_Login_Logout
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Navigate to Netflix App
    [Documentation]    Navigate to netflix APP in Apps Store via Main Menu
    [Setup]    Default First TestCase Setup
    I open Apps through Main Menu
    I focus App Store in TV APPS for app
    I Select TV App    ${APP_Netflix}

Validate Netflix app is launched
    [Documentation]    Validate if netflix is launched
    [Setup]    Skip If Last Fail
    set context    Launch_Netflix
    log action    ApplicationLaunched
    Run Keyword And Assert Failed Reason    I check '${APP_Netflix}' App is loaded    'Netflix APP not launched properly'
    log action    ApplicationLaunched_Done

I Login Netflix app and Enter Email ID
    [Documentation]    Login Netflix app and Enter Email ID
    [Setup]    Skip If Last Fail
    I Press   LEFT
    I wait for 0.5 seconds
    I Press   OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	0
    I wait for 0.5 seconds
    I Press    	0
    I wait for 0.5 seconds
    I Press    	1
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds

I Enter Netflix Password
    [Documentation]    Enter password for netflix
    [Setup]    Skip If Last Fail
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	LEFT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	UP
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	0
    I wait for 0.5 seconds
    I Press    	0
    I wait for 0.5 seconds
    I Press    	1
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds

I Logout from Netflix
    [Documentation]    Logout from Netflix
#    [Setup]    Skip If Last Fail
    I Press    	BACK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	RIGHT
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	DOWN
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds
    I Press    	OK
    I wait for 0.5 seconds