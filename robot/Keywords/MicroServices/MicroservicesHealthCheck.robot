*** Settings ***
Documentation     Keywords to check health of Microservices
Library           ../../Libraries/Backend/OBOQBR/
Library           ../../Libraries/MicroServices/EpgService/
Resource          ../basic.robot
Resource          ../mservice.basic.robot

*** Keywords ***
Customer Provisioning Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_PROVISIONING
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    Customer Provisioning Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve CPS healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    CPS info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Customer Provisioning Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_PROVISIONING
    ${http_response}    Health Check Detail    ${LAB_CONF}    Customer Provisioning Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve CPS healthcheck info url:
    ${json_response}    Set Variable If    ${http_response.status_code} == 200    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    CPS health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Discovery Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_DISCOVERYSERVICE
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    Discovery Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve Discovery Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Discovery Service info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Discovery Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_DISCOVERYSERVICE
    ${http_response}    Health Check Detail    ${LAB_CONF}    Discovery Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve Discovery Service healthcheck info url:
    ${json_response}    Set Variable    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Discovery Service health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Epg Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_EPGSERVICE
    ${http_response}    EpgService.Health Check Info    ${LAB_CONF}    ${LAB_CONF}["country"]    ${LAB_CONF}["default_language"]
    Should Be True    ${http_response.status_code} != ${None}    EpgService Health Check Info returned empty result
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve EPG Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    EPG Service info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

OMW Notification Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_NOTIFICATIONSERVICE
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    OMW Notification Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve OMW Notification Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    OMW Notification info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

OMW Notification Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_NOTIFICATIONSERVICE
    ${http_response}    Health Check Detail    ${LAB_CONF}    OMW Notification Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve OMW Notification Service healthcheck info url:
    ${json_response}    Set Variable    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    OMW Notification Service health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Purchase Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_PURCHASESERVICE
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    Purchase Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve Purchase Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Purchase Service info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Purchase Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_PURCHASESERVICE
    ${http_response}    Health Check Detail    ${LAB_CONF}    Purchase Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve Purchase Service healthcheck info url:
    ${json_response}    Set Variable    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Recording Service health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Recording Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_RECORDINGSERVICE
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    Recording Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve Recording Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Recording Service info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Recording Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_RECORDINGSERVICE
    ${http_response}    Health Check Detail    ${LAB_CONF}    Recording Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve Recording Service healthcheck info url:
    ${json_response}    Set Variable    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Recording Service health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Session Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_SESSIONSERVICE
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    Session Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve Session Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Session Service info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

Session Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_SESSIONSERVICE
    ${http_response}    Health Check Detail    ${LAB_CONF}    Session Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve Session Service healthcheck info url:
    ${json_response}    Set Variable    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    Session Service health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

VOD Service Info    #USED
    [Documentation]    Keyword to check the Info of Microservice
    [Tags]    TOOL_VODSERVICE
    ${http_response}    OBOQBR.Health Check Info    ${LAB_CONF}    VOD Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == None    Log Response    ${http_response}    ${failedReason} Could Not retrieve VOD Service healthcheck info url:
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    VOD Service info check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}

VOD Service Detail    #USED
    [Documentation]    Keyword to check the Detail of Microservice
    [Tags]    TOOL_VODSERVICE
    ${http_response}    Health Check Detail    ${LAB_CONF}    VOD Service
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    ${failedReason}    Run Keyword If    ${http_response.status_code} == ${None}    Log Response    ${http_response}    ${failedReason} Could Not retrieve VOD Service healthcheck info url:
    ${json_response}    Set Variable    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Check Healthy Status    ${json_response}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != ${None} and ${http_response.status_code} != 200    Set Variable    VOD Service health-check returns ${http_response.status_code}
    ...    ELSE    Set Variable    ${failedReason}
    Run Keyword If    ${failedReason} != ${NONE}    Fail    ${failedReason}