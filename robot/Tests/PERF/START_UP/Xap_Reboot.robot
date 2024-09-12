*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        Xap_Reboot
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author              Khushal M jain

*** Test Cases ***
Reboot(via xap) and verify if stb is up
    [Documentation]    Keyword to reboot STB
    set context    Xap_Reboot
    Run Keyword And Ignore Error    Reboot    ${LAB_CONF}    ${CPE_ID}
    Log To Console    Rebooting CPE: ${CPE_ID}
    I wait for 5 seconds
    log action    Reboot
    I wait for 30 seconds
    wait until keyword succeeds    300s   ${DEFAULT_RETRY_INTERVAL}    Box is connected and up after reboot
    log action    Reboot_Done
