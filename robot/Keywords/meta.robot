*** Settings ***
Library           SSHLibrary
Library           String
Library           Collections
Library           OperatingSystem
Library           ../Libraries/MetaKeywords/

*** Keywords ***
Setup Faker Customer
    [Tags]    TOOL_ITFAKER
    ${http_response}    Get Faker Customer    ${LAB_CONF}    ${CPE_ID}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != 200    Log Response    ${http_response}    ${failedReason} Could Not retrieve IT Faker url:
    ${json_response}    Set Variable If    ${http_response.status_code} == 200    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Log    ${json_response}
    Run Keyword If    ${http_response.status_code} == 200    Set Suite Variable    ${customer_id}    ${json_response['description']['customerId']}

# IT Faker faild workaround :

#    Run Keyword If    ${http_response.status_code} != 200   Set Suite Variable    ${customer_id}    ff8708d0-1712-11e8-ae89-c3c0e0a1f31d
#    Run Keyword If    ${http_response.status_code} != 200   Set Suite Variable    ${failedReason}    ${EMPTY}

    Run Keyword If    ${http_response.status_code} != 200   Set Suite Variable    ${failedReason}    ${failedReason}
    ...    ELSE    Set Suite Variable    ${failedReason}    ${EMPTY}

Setup Traxis Customer
    ${http_response}    Get Traxis Customer    ${LAB_CONF}    ${CPE_ID}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    Run Keyword If    ${http_response.status_code} != 200    Log Response    ${http_response}
    ${failedReason}    Set Variable If    ${http_response.status_code} != 200    Cannot get Customer id    ${EMPTY}
    ${json_response}    Set Variable If    ${http_response.status_code} == 200    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Set Suite Variable    ${customer_id}    ${json_response['Profiles']['Profile'][0]['id'].split("~")[0]}
    ...    ELSE    Set Suite Variable    ${failedReason}    ${failedReason}
    Run Keyword If    ${http_response.status_code} == 200    Set Suite Variable    ${CUSTOMER_ID}    ${json_response['Profiles']['Profile'][0]['id'].split("~")[0]}
    ...    ELSE    Set Suite Variable    ${failedReason}    ${failedReason}
    Log    ${CUSTOMER_ID}

Check Key In List
    [Arguments]    ${key}    @{list}
    [Documentation]    This keyword checks if the key exists in passed list otherwise fails.
    ${failedReason}    Set Variable If    '''${key}''' in '''${list}'''    ${EMPTY}    Response does not contain ${key} as key
    Should Be Empty    ${failedReason}

Check Data Regexp
    [Arguments]    ${data}    ${pattern}    ${name}
    [Documentation]    This keyword checks if the data matches the pattern otherwise fails.
    ${return}    Run Keyword And Return Status    Should Match Regexp    ${data}    ${pattern}
    ${failedReason}    Set Variable If    '''${return}''' == 'False'    ${name} format is incorrect.    ${EMPTY}
    Should Be Empty    ${failedReason}

Fetch Profile Id
    ${http_response}    Get Profile Id    ${LAB_CONF}    ${CUSTOMER_ID}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${http_response.status_code}    200
    Run Keyword If    ${http_response.status_code} != 200    Log Response    ${http_response}
    ${failedReason}    Set Variable If    ${http_response.status_code} != 200    Cannot get profile id    ${EMPTY}
    ${json_response}    Set Variable If    ${http_response.status_code} == 200    ${http_response.json()}
    Run Keyword If    ${http_response.status_code} == 200    Set Test Variable    ${profile_id}    ${json_response[0]['profileId']}
    ...    ELSE    Set Test Variable    ${failedReason}    ${failedReason}
    Should Be Empty    ${failedReason}
    [Return]    ${profile_id}