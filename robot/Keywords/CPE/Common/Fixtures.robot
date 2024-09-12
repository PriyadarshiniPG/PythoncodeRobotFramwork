*** Settings ***
Documentation     Setup and Teardown keywords
Resource          ../../MicroServices/PersonalizationService/PersonalizationService_Keywords.robot

*** Keywords ***
Basic Suite Setup    #USED
    [Documentation]    This keyword contains the Basic Suite setup steps for running the tests, It is using ls
    ...    the rack_detai.YML RACK_SLOT_ID and OBELIX env variables - those env vars can be provided by JENKINS
    ...    local run example example: --variable=RACK_SLOT_ID:FCOBOS_RACK_SLOT_ID  --variable=ELASTIC:False
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    #THIS PABOT VARIABLE WILL INDICATE THAT WE ARE RUNING THE TESTS USING PABOT or NOT
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${PABOT}
    ${PABOT}    Set Variable If    ${status} == True    ${PABOT}    False
    ${PABOT}    Get Environment Variable    PABOT    ${PABOT}
    Set Suite Variable    ${PABOT}    ${PABOT}    children=${True}
    Run Keyword if    '${PABOT}' == 'True'    run keywords    log    RUNNING with PABOT: ${PABOT}
    ...    AND    log to console    RUNNING with PABOT: ${PABOT}
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${SUITE_ID}
    Run Keyword if    ${status} == True and '${PABOT}' == 'True'    Log To Console    \n\n### WARN: PABOT: True But SUITE_ID - NOT PROVIDED - AUTO Generated ###\n\n
    ${status}    Run Keyword And Return Status    Get Environment Variable    RACK_SLOT_ID    ${RACK_SLOT_ID}
    Run Keyword if    '${PABOT}' == 'False' and ${status} == False    Log To Console    \n\n### ERROR: RACK_SLOT_ID - NOT PROVIDED ###\n\n
    ${RACK_SLOT_ID}    Run Keyword if    '${PABOT}' == 'False'    Get Environment Variable    RACK_SLOT_ID    ${RACK_SLOT_ID}  # This variable is expected to be defined in Jenkins
    ${status}    Run Keyword And Return Status    Get Environment Variable    LAB_NAME    ${LAB_NAME}
    Run Keyword if    ${status} == False    Log To Console    \n\n### ERROR: LAB_NAME - NOT PROVIDED ###\n\n
    ${LAB_NAME}    Get Environment Variable    LAB_NAME    ${LAB_NAME}  # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${LAB_NAME}    ${LAB_NAME}    children=${True}
    Log To Console    LAB_NAME: ${LAB_NAME}
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${CAPTURE_SCREENSHOT}
    ${CAPTURE_SCREENSHOT}    Set Variable If    ${status} == True    ${CAPTURE_SCREENSHOT}    False
    ${CAPTURE_SCREENSHOT}    Get Environment Variable    CAPTURE_SCREENSHOT    ${CAPTURE_SCREENSHOT}
    Set Suite Variable    ${CAPTURE_SCREENSHOT}    ${CAPTURE_SCREENSHOT}    children=${True}
    # FROM LAB_NAME We create LAB_CONF (using conf_{ENV}.py file to get E2E_CONF variable => E2E_CONF["${LAB_NAME}"])
    Set Suite Variable    ${LAB_CONF}    ${E2E_CONF["${LAB_NAME}"]}    children=${True}
    Get Elastic Environments Variables
    Get Default Jenkins Environments Variables
    ${XAP}    Get Environment Variable    XAP    ${True}    # This variable should ALLWAYS be True - To use XAP
    ${DEGRADEDMODE}    Get Environment Variable    DEGRADEDMODE    ${False}    # This variable should ALLWAYS be False
    ${OSD_LANGUAGE}    Get Environment Variable    OSD_LANGUAGE    default  # This variable will be fix to 'en' on StbAllocation if value is "Default"
    Set Suite Variable    ${XAP}    ${XAP}    children=${True}
    Set Suite Variable    ${DEGRADEDMODE}    ${DEGRADEDMODE}    children=${True}
    Set Suite Variable    ${OSD_LANGUAGE}    ${OSD_LANGUAGE}
    Clean Variables      #basic.robot To create failedReason and resultLink suite variables
    Set textKey identifiers     #TO FIX THE MAIN MENU textKey VALUES
    Allocate STB
    Set Suite Variable    ${RACK_SLOT_ID}    ${RACK_SLOT_ID}    children=${True}
    Log    RACK_SLOT_ID: ${RACK_SLOT_ID}
    Log To Console    RACK_SLOT_ID: ${RACK_SLOT_ID}
    Check Local or Datacenter CPE and Check If Linear RF Feed Is Present

Get Elastic Environments Variables    #USED
    [Documentation]    This keyword will indicate if we are ingesting or not data to elasticsearch by default it will be True
    #THIS ELASTIC VARIABLE WILL INDICATE THAT WE ARE INGESTING OR NOT DATA TO ELASTICSEARCH by default It will be True
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${ELASTIC}
    ${ELASTIC}    Set Variable If    ${status} == True    ${ELASTIC}    True
    ${ELASTIC}    Get Environment Variable    ELASTIC    ${ELASTIC}
    Set Suite Variable    ${ELASTIC}    ${ELASTIC}    children=${True}
    # Getting the Tenant conf for Elastic ingest: enable/disable variable "ELASTIC_TENANT" on E2E_CONF["${LAB_NAME}"]
    # by default ELASTIC_TENANT will be True if is not present on config_{ENV}.py for a specific tenant
    ${status}    Run Keyword And Return Status    Set Suite Variable    ${ELASTIC_TENANT}    ${E2E_CONF["${LAB_NAME}"]["ELASTIC_TENANT"]}    children=${True}
    ${ELASTIC_TENANT}    Set Variable If    ${status} == False    True    ${E2E_CONF["${LAB_NAME}"]["ELASTIC_TENANT"]}
    log to console    ELASTIC_TENANT: ${ELASTIC_TENANT}
    Run Keyword if    '${ELASTIC}' == 'True' and '${ELASTIC_TENANT}' == 'False'     Set Suite Variable    ${ELASTIC}    False

Get Default Jenkins Environments Variables    #USED
    [Documentation]    This keyword will get all the useful environments variables that Jenkins Created
    ${SUITE_ID}    Get Environment Variable    SUITE_ID    ${EMPTY}  # This variable is expected to be defined in Jenkins
    ${PIPELINE_ID}    Get Environment Variable    PIPELINE_ID    ${EMPTY}  # This variable is expected to be defined in Jenkins
    ${JOB_NAME}    Get Environment Variable    JOB_NAME    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself [JOB NAME]
    ${USER_ID}    Get Environment Variable    USER    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${BUILD_NUMBER}    Get Environment Variable    BUILD_NUMBER    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${BUILD_URL}    Get Environment Variable    BUILD_URL    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${BUILD_TAG}    Get Environment Variable    BUILD_TAG    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${GIT_BRANCH}    Get Environment Variable    GIT_BRANCH    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${GIT_COMMIT}    Get Environment Variable    GIT_COMMIT    ${EMPTY}  # This variable is expected to be defined by Jenkins Itself
    ${STB_POOL}    Get Environment Variable    STB_POOL    ${EMPTY}  # This variable is expected to be defined in Jenkins
# --variable=JOB_NAME:$JOB_NAME --variable=USER:$USER --variable=BUILD_NUMBER:$BUILD_NUMBER --variable=BUILD_URL:$BUILD_URL
# --variable=BUILD_TAG:$BUILD_TAG --variable=GIT_BRANCH:$GIT_BRANCH --variable=GIT_COMMIT:$GIT_COMMIT

Check Local or Datacenter CPE and Check If Linear RF Feed Is Present    #USED
    [Documentation]    This keyword will check if it is a Local CPE: ('ECX' or 'LOCAL') is present on the value of the 'RACK_SLOT_ID' Variable
    ...    Then if it is local we will check if the RF is Present for it
    run keyword if    'LOCAL' in '${RACK_SLOT_ID}' or 'ECX' in '${RACK_SLOT_ID}'    run keywords    log to console    INFO - Running on a LOCAL or ECX CPE
    ...    AND    Check If Linear RF Feed Is Present
    ...    ELSE    run keywords    log to console    INFO - Running on DATACENTER CPE
    ...    AND    set suite variable    ${RF_FEED_PRESENT}    ${True}
    Log    RF_FEED_PRESENT: ${RF_FEED_PRESENT}
    run keyword if    ${RF_FEED_PRESENT}    log to console    INFO - RF FEED Present for: ${RACK_SLOT_ID} - TENANT: ${LAB_NAME}

Check If Linear RF Feed Is Present    #USED
    [Documentation]    This keyword will be call if 'ECX' or 'LOCAL' is present on the value of the 'RACK_SLOT_ID' Variable
    ...    @{rf_feed_present_tenant_list} will contain the names of the tenants that we have RF FEED on Schiphol(Local)/ECX
    ...    So it will contain All the NL lab/Tenants
    @{rf_feed_present_tenant_list}    Create List	prod_nl    preprod_nl    labe2esi    labe2esuperset
    run keyword if    '${LAB_NAME}' in ${rf_feed_present_tenant_list}    set suite variable    ${RF_FEED_PRESENT}    ${True}
    ...    ELSE    run keywords    log to console    WARNING - NOT RF FEED Present for: ${RACK_SLOT_ID} - TENANT: ${LAB_NAME}
    ...    AND     set suite variable    ${RF_FEED_PRESENT}    ${False}

Minimal Suite Setup    #USED
    [Documentation]    This keyword contains the minimum setup steps to allocate source
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Basic Suite Setup
    Make sure that STB is active
#    Enable CPE Tools    #Use our XAP Library to Enable the testsTools - DONE IN "Disable tips and tricks" Keyword
    Disable tips and tricks    ##Enable the testsTools Set "app.isTipsAndTricksEnabled": false => tips/tricks are not show on UI
    Set all the tips as already shown in the past via as    #Set all tips as show - maybe redundant with "Disable tips and tricks" Keyword
    Get CPE build    #Suite Var: ${CPE_VERSION} Will contain the current Build CPE VERSION: 0XX-[A-Z][A-Z](get it by AS)
    STB Initial Software Version    #Suite Var: ${CPE_FULL_VERSION} Will contain the current CPE FULL VERSION(get it by AS)
    Set STB platform specific variables

#USING ITFAKER and HARDCODE CITY ID TO CHECK
#    Create missing profile

Default Suite Setup    #USED
    [Documentation]    This keyword executes Default Suite Setup And Assert Error and make sure error is causgh if belongs to Suit Setup
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Run Keyword And Assert Failed Reason    Default Suite Setup And Assert Error    Default Suite Setup failure

Default Suite Setup And Assert Error    #USED
    [Documentation]    This keyword contains the default setup steps for running the tests, doesn't use JSON.
    ...    It goes always to Linear as sanity for tests
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    set global variable     ${PERF_CHECK_XAP_TIMEDOUT}    False
    set global variable     ${XAP_TIMEOUT}    False
    Minimal Suite Setup
#    Read current country code     #Suite Var: ${COUNTRY} Will contain the COUNTRY (get it by AS - cpe.country)
    Get customer from as     #Suite Var: ${CUSTOMER_ID} Will contain the CUSTOMER ID (get it by AS - customer.customerId)
    I set osd language from appservices to ${OSD_LANGUAGE}
    Initalize variables for colour
    #Run Keyword If    '${PLATFORM}'!='SMT-G7400' and '${PLATFORM}'!='SMT-G7401'    Disable Pairing Device popup by spoofing paired device status
    Default First TestCase Setup
    Check If Account Not Suspended
    Basic Sanity go to Linear    #This keyword try to go to Linear From Any Situation - used as Sanity

Check If Account Not Suspended    #USED
    [Documentation]  The keyword checks if the account is suspended or not. If the account is suspended the customer status will be INACTIVE otherwise it will be ACTIVE
    ${profile_details}    I Get The Profile Details From BO
    ${customer_status}   Extract Value For Key    ${profile_details}    ${EMPTY}   customerStatus
    Should Be Equal    ${customer_status}    ACTIVE    Account is suspended

Basic Sanity go to Linear    #USED
    [Documentation]    This keyword try to go to Linear From Any Situation - used as Sanity
    I Press    GUIDE    #To go out from Youtube APP for example
    sleep    4s
    I press    LIVETV

Default First TestCase Setup    #USED
     Get cityID via personalization service if it is default

Get customer from as    #USED
    [Documentation]    This keyword try to retrieve the customerID from the application services settings
    ${CUSTOMER_ID}    Get application service setting    customer.customerId
    log to console    CUSTOMER_ID: ${CUSTOMER_ID}
    set suite variable  ${CUSTOMER_ID}    ${CUSTOMER_ID}

Debug Default Suite Setup    #USED
    [Documentation]    This keyword contains the default setup steps for running the tests, doesn't use JSON.
    ...    It goes always to Linear as sanity for tests
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Minimal Suite Setup
    Read current country code     #Suite Var: ${COUNTRY} Will contain the COUNTRY CODE (get it by AS)
    I set osd language from appservices to ${OSD_LANGUAGE}
    Initalize variables for colour
    Run Keyword If    '${PLATFORM}'!='SMT-G7400' and '${PLATFORM}'!='SMT-G7401'    Disable Pairing Device popup by spoofing paired device status

Default Suite Teardown    #USED
    [Documentation]    This keyword contains the basic common teardown steps for the tests. Doesn't use JSON.
    Log    Common Suite Teardown
    Release STB
#    Delete All Sessions

Functional Specific Suite Setup    #NOT_USED
    [Documentation]    This keyword contains the Functional Tests specific Setup Steps. Uses JSON.
    # TODO - RE-CHECK as it is using ITfaker and hardocde data
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Run Keyword Unless    '${VERSION}' == 'DoNotUpgrade'    Make sure that STB is running with given version
    Make sure that STB is not in standby
    Run Keyword If    '${MOUNT_BRANCH}' == '${True}'    Mount branch
    Run Keyword if    '${JSON}' == 'True'    I Want To Enable Json Handler Function
    Make sure that localization is correct
    # THIS KEYWORD IS USING A LIB THAT USE SSH:     Make sure STB is not in degraded mode
    Run Keyword if    '${ADD_PRODUCTS}' == 'True'    add all products with itfaker
    Run Keyword if    '${CA}' == 'True'    Initialize full package
    Set textKey identifiers
    I Set Age Rating Of The STB To Off
    Reset STB Logs Via Serial
    disable tips and tricks

FTI Minimal Suite Setup    #NOT_USED
    [Documentation]    This keyword contains the minimum setup steps to allocate source and perform FTI actions
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Minimal Suite Setup
    Check IR connectivity
    # This 'Make sure the STB is not in cold standby' keyword is ussing the serial and it should not use it
#    Make sure the STB is not in cold standby
# 'Verify the build is available in CDN'  keyword  is using the SSH lib - is in UpdateOperation_Keywords.robot 
#    Run Keyword Unless    '${VERSION}' == 'DoNotUpgrade'    Verify the build is available in CDN

Setting Specific Suite Setup   #NOT_USED
    [Documentation]    This keyword contains the Default and Setting Tests specific Setup Steps.
    Default Suite Setup
    Save the original CPE product list

Parental Suite Setup   #NOT_USED
    [Documentation]    This keyword contains the Default and Parental Tests specific Setup Steps.
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    set suite variable    ${age_navigation_id}    DIC_SETTINGS_OPTION_OFF
    Default Suite Setup

Parental Suite Teardown   #NOT_USED
    [Documentation]    This keyword contains the Default and Parental Tests specific Teardown Steps.
    I Set Age Rating Of The STB To Off
    Default Suite Teardown

Parental and clear locked channel list suite Teardown   #NOT_USED
    [Documentation]    This keyword executes the kw 'Parental Suite Teardown', and clears locked channel list
    I Set Age Rating Of The STB To Off
    Clear Locked Channel List In Teardown
    Default Suite Teardown

Language Specific Suite Setup    #NOT_USED
    [Arguments]    ${lang}
    [Documentation]    Sets language to given before running test
    Default Suite Setup
    I set osd language from appservices to ${lang}

Localizations Specific Suite Setup    #NOT_USED
    [Arguments]    ${country}    ${osd_lang}
    [Documentation]    Sets languages to given before running localization test
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Common Suite Setup
    STB Initial Software Version
    The CPE is installed in    ${country}
    Functional Specific Suite Setup
    I set osd language from appservices to ${osd_lang}
    STB Under Test Software Version
    Run Keyword If    '${PLATFORM}'!='SMT-G7400' and '${PLATFORM}'!='SMT-G7401'    Disable Pairing Device popup by spoofing paired device status

Default Suite Setup with channel verification   #NOT_USED
    [Arguments]    @{channel_list}
    [Documentation]    Default Suite Setup and verification that Traxis data is present for all passed channels
    Default Suite Setup
    Channel Data Verification    @{channel_list}

Teletext Specific Teardown   #NOT_USED
    [Documentation]    This comes out of teletext mode
    I press    BACK
    I open Channel Bar
    both audio and video are playing out

Linear Specific Suite Setup    #USED
    [Documentation]    This Suite Setup is Specific To Linear Tests
    Default Suite Setup
    Run Keyword And Assert Failed Reason    I Set Age Rating Of The STB To Off    Unable to set age rating of STB to off
