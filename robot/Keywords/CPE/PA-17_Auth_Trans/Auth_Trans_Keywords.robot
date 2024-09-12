*** Settings ***
Documentation     Keywords related to CPE provisioning
Resource          ../Common/Common.robot

*** Variables ***
@{AUTOMATION_NEEDED_PRODUCTS}    142    200000000

*** Keywords ***
I provision ${product} entitlement
    [Documentation]    This Keyword is used to provision product id details from ITC tool
    initialize products    ${CA_ID}    ${product}

I remove ${product} entitlement
    [Documentation]    This Keyword is used to remove product id details from ITC tool
    remove products    ${CA_ID}    ${product}

I am not subscribed to svod products
    [Documentation]    This Keyword is used to remove SVOD product via ITC tool
    delete products by feature    VOD    ${LAB_TYPE}    ${CPE_ID}

I am subscribed to svod products
    [Documentation]    This Keyword is used to add SVOD product via ITC tool
    add products by feature    VOD    ${LAB_TYPE}    ${CPE_ID}

I cancel all CA entitlements
    [Documentation]    This Keyword is used to cancel The CA Entitlements
    cancel all products    ${CA_ID}

I add all CA entitlements
    [Documentation]    This Keyword is used to add all the CA Entitlements
    Initialize full package

I tune to channel with HD 1 service
    [Documentation]    This Keyword is used to tune to Channel with HD 1 service
    tune to channel ${HD1_CHANNEL}

I tune to channel with SD ALL service
    [Documentation]    This Keyword is used to tune to Channel with SD ALL service
    I tune to channel    ${SD_ALL_CHANNEL}

I tune to channel with SD 1 service
    [Documentation]    This Keyword is used to tune to Channel with SD 1 service
    tune to channel ${SD1_CHANNEL}

channel is unlocked within one EMM cycle time
    [Documentation]    This Keyword is used to Channel is unlocked within one EMM cycle time
    wait until keyword succeeds    ${EmmCycleTime}    10 s    content available

channel is locked within one EMM cycle time
    [Documentation]    This Keyword is used to Channel is locked within one EMM cycle time
    wait until keyword succeeds    ${EmmCycleTime}    10 s    content unavailable

reset ca default settings
    [Documentation]    This Keyword is used to reset ca default settings
    I Set Age Rating Of The STB To Off

CA Suite Setup
    [Documentation]    This Keyword is used to reset CA default settings
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Default Suite Setup
    reset ca default settings
    I tune to channel    ${HD1_Channel}
    wait until keyword succeeds    ${EmmCycleTime}    10s    content available
    I cancel all CA entitlements
    wait until keyword succeeds    ${EmmCycleTime}    10s    content unavailable

CA Suite Teardown
    [Documentation]    This Keyword is used to CA Suite Teardown
    I add all CA entitlements
    add all products with itfaker
    Default Suite Teardown

STB is entitled to HD1 services
    [Documentation]    This keyword is used to Entitled the HD 1 service
    I tune to channel with HD 1 service
    I provision HD+1 entitlement
    wait until keyword succeeds    ${EmmCycleTime}    10 s    content available

STB is entitled to SD1 services
    [Documentation]    This keyword is used to Entitled the SD 1 service
    I tune to channel with SD 1 service
    I provision SD+1 entitlement
    wait until keyword succeeds    ${EmmCycleTime}    10 s    content available

I am not entitled to the SD1 Service
    [Documentation]    Remove entitlement, tune to the SD1 service and verify the content is not available
    I remove SD+1 entitlement
    I tune to channel with SD 1 service
    wait until keyword succeeds    ${EmmCycleTime}    10s    content unavailable

I am not entitled to the HD1 Service
    [Documentation]    Remove entitlement, tune to the HD1 service and verify content is not available
    I remove HD+1 entitlement
    I tune to channel with HD 1 service
    wait until keyword succeeds    ${EmmCycleTime}    10s    content unavailable
