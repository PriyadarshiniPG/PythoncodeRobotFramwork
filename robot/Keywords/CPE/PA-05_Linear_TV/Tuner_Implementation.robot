*** Settings ***
Documentation     Tuner implementation keywords
Resource          ../Common/Common.robot

*** Keywords ***
Get Number Of Available Tuners
    [Documentation]    Returns total free tuners available
    ${free_tuner_count}    get total free tuners via vldms    ${STB_IP}    ${CPE_ID}
    [Return]    ${free_tuner_count}

Get Number Of Total Tuners
    [Documentation]    Returns total tuners
    ${total_tuner_count}    get total tuners via vldms    ${STB_IP}    ${CPE_ID}
    [Return]    ${total_tuner_count}
