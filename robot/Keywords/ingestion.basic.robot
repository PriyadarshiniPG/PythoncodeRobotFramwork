*** Settings ***
Library           OperatingSystem
Library           ../Libraries/IngestionE2E/
Library           Collections
Resource          basic.robot

*** Keywords ***
Suite Setup Ingestion Variables
    ${LAB_NAME}    Get Environment Variable    LAB_NAME    ${LAB_NAME}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${LAB_NAME}    ${LAB_NAME}    children=${True}
    ${SINGLE_LOGS_HOST}    Get Environment Variable    SINGLE_LOGS_HOST    ${True}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${SINGLE_LOGS_HOST}    ${SINGLE_LOGS_HOST}    children=${True}
    Set Suite Variable    ${LAB_CONF}    ${E2E_CONF["${LAB_NAME}"]}
    Log Dictionary    ${LAB_CONF}
    Set Suite Variable    ${firstTestCaseFail}    ${EMPTY}
    Set Suite Variable    ${failedReason}    ${EMPTY}

Check Connection To Airflow Workers
    ${error}    Check Airflow Logging Enabled    ${LAB_NAME}    ${E2E_CONF}
    [Return]    ${error}

Check Connection To Transcoders
    ${error}    Check Transcoders Connectivity    ${LAB_NAME}    ${E2E_CONF}
    [Return]    ${error}

Unlock Packages
    [Arguments]    ${map_dict}
    ${errors}    Create List
    Log    ${map_dict}
    ${map_dict_keys}    Get Dictionary Keys    ${map_dict}
    :FOR    ${jira_ticket}    IN    @{map_dict_keys}
    \    Log    ${jira_ticket}
    \    Log    ${map_dict["${jira_ticket}"]["packages"]}
    \    ${errs}    Unlock Package In Watch    ${LAB_NAME}    ${E2E_CONF}    ${map_dict["${jira_ticket}"]["packages"]}
    \    Append To List    ${errors}    @{errs}
    ${errors_str}    Concatenate List Values    ${errors}    .${SPACE}
    Log    ${errors_str}
    [Return]    ${errors_str}

Run No OG Ingestion Suite
    [Arguments]    ${map_dict}    ${tries}=200    ${interval}=120    # by default: 60 attempts with 2 min interval - two hours max to wait ingestion results
    ${results}    Get Ingestion Results    ${LAB_NAME}    ${E2E_CONF}    ${map_dict}    ${tries}    ${interval}
#    # Debug:
#    ${results}    Set Variable    ${MOCK_DATA["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]}
    Log    ${results}
    Set Suite Variable    ${RESULTS}    ${results}    children=true

Run Ingestion Suite
    [Arguments]    ${map_dict}    ${tries}=200    ${interval}=120    ${get_results}=${True}    # by default: 60 attempts with 2 min interval - two hours max to wait ingestion results
#
#    # DEBUG: Uncomment me and comment everything below me =)
#    # Part 1 ("Get Ingestion Results" check):
#    ${packages}    Set Variable    ${MOCK_DATA["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["packages"]}
#    ${results}    Get Ingestion Results    ${LAB_NAME}    ${E2E_CONF}    ${packages}    ${tries}    ${interval}
#    # Part 2 (tests check):
#    ${results}    Set Variable    ${MOCK_DATA["robot"]["Keywords"]["ingestion.basic.robot"]["Run Ingestion Suite"]["results"]}
#    Set Suite Variable    ${RESULTS}    ${results}    children=true
#
    ${packages}    Generate Offers    ${LAB_NAME}    ${E2E_CONF}    ${map_dict}
    Log    ${packages}
    ${results}    Run Keyword If    ${get_results}==${True}    Get Ingestion Results    ${LAB_NAME}    ${E2E_CONF}    ${packages}    ${tries}    ${interval}
    Run Keyword If    ${get_results}==${True}    Log    ${results}
    Run Keyword If    ${get_results}==${True}    Set Suite Variable    ${RESULTS}    ${results}    children=true
    Run Keyword If    ${get_results}!=${True}    Set Suite Variable    ${packages}    ${packages}    children=true

Check Asset Failed
    [Arguments]    ${jira_ticket_id}
    ${full_res_keys}    Get Dictionary Keys    ${RESULTS}
    ${errors}    Set Variable If    "error" in ${full_res_keys}    ${RESULTS["error"]}    ${EMPTY}
    ${res}    Run Keyword If    "error" in ${full_res_keys}    Create Dictionary
    ...    ELSE    Set Variable    ${RESULTS["${jira_ticket_id}"]["packages"]}
    ${packages_res_keys}    Get Dictionary Keys    ${res}
    ${ticket_res_keys}    Get Dictionary Keys    ${RESULTS["${jira_ticket_id}"]}
    ${errors}    Set Variable If    "error" in ${ticket_res_keys}    ${RESULTS["${jira_ticket_id}"]["error"]}    ${EMPTY}
    Should Be Empty    ${errors}    ${errors}
    Should Be Empty    ${failedReason}    ${failedReason}
    : FOR    ${package}    IN    @{packages_res_keys}
    \    Log    ${package}
    \    ${res_values}    Get Dictionary Values    ${res}
    \    ${package_data}    Set Variable    ${res_values[0]}
    \    Log    ${package_data}
    \    ${errors}    Set Variable    ${package_data["errors"]}
    \    Log    ${errors}
    Should Not Be Empty    ${errors}    Asset was not failed
    [Return]    ${errors}

Check Movie Type Has Been Ingested
    [Arguments]    ${jira_ticket_id}    ${movie_type}    ${platform_type}=${EMPTY}
    [Documentation]    This keyword analyzes has particular movie type (as OTT or STB) been ingested
    Log    ${movie_type}
    ${data}    Set Variable    ${RESULTS["${jira_ticket_id}"]["packages"]}
    ${data_keys}    Get Dictionary Keys    ${data}
    : FOR    ${package}    IN    @{data_keys}
    \    Log    ${package}
    \    ${package_data}    Set Variable    ${data["${package}"]}
    \    Log    ${package_data}
    \    ${result}    Run Keyword If     "${platform_type}" != "${EMPTY}"    Set Variable    ${package_data["${platform_type}_${movie_type}_movie_has_been_ingested"]}
    ...    ELSE IF    "${platform_type}" == "${EMPTY}"    Set Variable    ${package_data["${movie_type}_movie_has_been_ingested"]}
    ...    ELSE    Set Variable    ${None}
    Should Not Be Equal    ${result}    ${None}    Result of ingestion ${movie_type} was not fount
    Log    ${result}
    [Return]    ${result}

Check Packages Ingested
    [Arguments]    ${jira_ticket_id}
    [Documentation]    This keyword analyzes values in the suite variable RESULTS - for instance, for Jira ticket HES-10, the value RESULTS["HES-10"] should be available (this can be done by 'Suite Setup Bunch Spoil ADI' and 'Suite Setup Bunch Positives' keywords in ingestion.basic.robot Keywords).
    ...
    ...    Sample of RESULTS value:
    ...    {'HES-137':
    ...    {'errors': [u'Failed to connect to lgiobo.stage.ott.irdeto.com: timed out'],
    ...    'start_time': 20181220105125,
    ...    'end_time': 20181220124605,
    ...    'airflow_asset_id': u'ts0000_20170908_064158pt',
    ...    'package_id': '1504859990.47',
    ...    'fabrix_asset_id': None,
    ...    'sample_id': u'ts0000',
    ...    'properties': None,
    ...    'logs_masks': [u'/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:16.282893', u'/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']},
    ...    {'HES-74':
    ...    {'errors': [u"Bad checksum for the 'ts0000_20170908_064153pt1.ts' video file (actual: 3db98b518644918080e48343bdb644a1, \ \ \ \ expected: abc)"],
    ...    'airflow_asset_id': u'ts0000_20170908_064153pt',
    ...    'package_id': '1504859984.53',
    ...    'fabrix_asset_id': None,
    ...    'sample_id': u'ts0000',
    ...    'properties': None,
    ...    'logs_masks': [u'/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:20.620621', u'/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']}
    ...    }
    ${res_ticket_keys}    Get Dictionary Keys    ${RESULTS["${jira_ticket_id}"]}
    ${errors}    Set Variable If    "error" in ${res_ticket_keys}    ${RESULTS["${jira_ticket_id}"]["error"]}    ${EMPTY}
    Set Suite Variable    ${failedReason}    ${errors}
    Should Be Empty    ${failedReason}    ${failedReason}
    ${res_keys}    Get Dictionary Keys    ${RESULTS}
    ${errors}    Set Variable If    "error" in ${res_keys}    ${RESULTS["error"]}    ${errors}
    ${res}    Run Keyword If    "error" in ${res_keys}    Create Dictionary
    ...    ELSE    Set Variable    ${RESULTS["${jira_ticket_id}"]["packages"]}
    ${res_ticket_keys}    Get Dictionary Keys    ${res}
    : FOR    ${package}    IN    @{res_ticket_keys}
    \    Log    ${package}
    \    ${package_data}    Set Variable    ${res["${package}"]}
    \    Log    ${package_data}
    \    ${errors}    Concatenate List Values    ${package_data["errors"]}    ;${SPACE}
    \    Log    ${errors}
    \    ${status}    Run Keyword And Return Status    Should Be Empty    ${errors}
    \    ${failedReason}    Set Variable If    ${status}    ${failedReason}    ${failedReason}. Unexpected error(s) occured while trying to ingest a package '${package}' for JIRA ticket ${jira_ticket_id}: ${errors}
    \    ${status}    Run Keyword And Return Status    Should Match Regexp    ${package_data["fabrix_asset_id"]}    [0-9a-f]{32}_[0-9a-f]{32}
    \    ${failedReason}    Set Variable If    ${status}    ${failedReason}    ${failedReason}. Package '${package}' for JIRA ticket ${jira_ticket_id} has not been passed to Fabrix
    \    ${properties}    Evaluate    json.dumps("""${package_data["properties"]}""")    json
    \    Log    ${properties}
    \    Log    ${package_data["fabrix_asset_id"]}
    \    ${status}    Run Keyword And Return Status    Should Contain    ${properties}    ${package_data["fabrix_asset_id"]}
    \    ${failedReason}    Set Variable If    ${status}    ${failedReason}    ${failedReason}. Package '${package}' for JIRA ticket ${jira_ticket_id} has not been ingested
    Set Suite Variable    ${failedReason}    ${failedReason}
    Should Be Empty    ${failedReason}    ${failedReason}
    [Return]    ${errors}

Get Package Ingestion start and end time
    [Arguments]    ${jira_ticket_id}
    [Documentation]    This keyword analyzes values in the suite variable RESULTS and return package's ingestion start and end time
    ...
    ...    Sample of RESULTS value:
    ...    {'HES-137':
    ...    {'errors': [u'Failed to connect to lgiobo.stage.ott.irdeto.com: timed out'],
    ...    'start_time': 20181220105125,
    ...    'end_time': 20181220124605,
    ...    'airflow_asset_id': u'ts0000_20170908_064158pt',
    ...    'package_id': '1504859990.47',
    ...    'fabrix_asset_id': None,
    ...    'sample_id': u'ts0000',
    ...    'properties': None,
    ...    'logs_masks': [u'/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:16.282893', u'/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']},
    ...    {'HES-74':
    ...    {'errors': [u"Bad checksum for the 'ts0000_20170908_064153pt1.ts' video file (actual: 3db98b518644918080e48343bdb644a1, \ \ \ \ expected: abc)"],
    ...    'airflow_asset_id': u'ts0000_20170908_064153pt',
    ...    'package_id': '1504859984.53',
    ...    'fabrix_asset_id': None,
    ...    'sample_id': u'ts0000',
    ...    'properties': None,
    ...    'logs_masks': [u'/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:20.620621', u'/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']}
    ...    }
    ${res_keys}    Get Dictionary Keys    ${RESULTS}
    ${errors}    Set Variable If    "error" in ${res_keys}    ${RESULTS["error"]}    ${EMPTY}
    ${packages}    Set Variable    ${RESULTS["${jira_ticket_id}"]["packages"]}
    ${final_result}    Create Dictionary
    ${packages_keys}    Get Dictionary Keys    ${packages}
    : FOR    ${package}    IN    @{packages_keys}
    \    ${package_result}    Create Dictionary
    \    Set To Dictionary    ${final_result}    ${package}=${package_result}
    \    Log    ${package}
    \    ${package_data}    Set Variable    ${packages["${package}"]}
    \    Log    ${package_data}
    \    ${start_time}    Set Variable    ${package_data["start_time"]}
    \    Log    ${start_time}
    \    Set To Dictionary    ${package_result}    start_time=${start_time}
    \    ${end_time}    Set Variable    ${package_data["end_time"]}
    \    Log    ${end_time}
    \    Set To Dictionary    ${package_result}    end_time=${end_time}
    Log    ${final_result}
    [Return]    ${final_result}

Check Packages Ingested And Update failedReason
    [Arguments]    ${jira_ticket_id}
    [Documentation]    This keyword analyzes values in the suite variable RESULTS - for instance, for Jira ticket HES-10, the value RESULTS["HES-10"] should be available (this can be done by 'Suite Setup Bunch Spoil ADI' and 'Suite Setup Bunch Positives' keywords in ingestion.basic.robot Keywords).
    ...
    ...    Sample of RESULTS value:
    ...    {'HES-137':
    ...    {'errors': [u'Failed to connect to lgiobo.stage.ott.irdeto.com: timed out'],
    ...    'start_time': 20181220105125,
    ...    'end_time': 20181220124605,
    ...    'airflow_asset_id': u'ts0000_20170908_064158pt',
    ...    'package_id': '1504859990.47',
    ...    'fabrix_asset_id': None,
    ...    'sample_id': u'ts0000',
    ...    'properties': None,
    ...    'logs_masks': [u'/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:16.282893', u'/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']},
    ...    {'HES-74':
    ...    {'errors': [u"Bad checksum for the 'ts0000_20170908_064153pt1.ts' video file (actual: 3db98b518644918080e48343bdb644a1, \ \ \ \ expected: abc)"],
    ...    'airflow_asset_id': u'ts0000_20170908_064153pt',
    ...    'package_id': '1504859984.53',
    ...    'fabrix_asset_id': None,
    ...    'sample_id': u'ts0000',
    ...    'properties': None,
    ...    'logs_masks': [u'/usr/local/airflow/logs/create_obo_assets_transcoding_driven_workflow/*/2017-09-12T06:51:20.620621', u'/usr/local/airflow/logs/e2esi_lab_create_obo_assets_transcoding_driven_trigger/*/2017-09-12T06:40:00']}
    ...    }
    ${errors}    Check Packages Ingested    ${jira_ticket_id}
    ${errors}    Set Variable    ${errors.replace("'","").replace('"', '')}    # Get rid of quotes to send this to ElasticSearch properly
    ${failedReason}    Set Variable If    """${errors}""" != ""    Asset for JIRA ticket ${jira_ticket_id} has not been ingested due to the following error(s): ${errors}.${SPACE}\n    ${EMPTY}
    Log    ${failedReason}
    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${failedReason}

Get Expected DAG name From Jenkins
    [Arguments]    ${var_name}=EXPECTED_DAG    ${default}=csi_lab_create_obo_assets_workflow
    ${EXPECTED_DAG}    Get Environment Variable    ${var_name}    ${default}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${EXPECTED_DAG}    ${EXPECTED_DAG}    children=true
    [Return]    ${EXPECTED_DAG}

Check movie has correct resolution and return failed reason
    [Arguments]    ${jira_ticket_id}    ${PACKAGE}    ${movie_type}    ${definition_type}
    ${output_tva}    Set Variable    ${RESULTS["${jira_ticket_id}"]["packages"]["${PACKAGE}"]["output_tva"]}
    ${failedReason}    Check movie has correct resolution    ${LAB_NAME}    ${E2E_CONF}    ${output_tva}    ${movie_type}    ${definition_type}
    [Return]    ${failedReason}
