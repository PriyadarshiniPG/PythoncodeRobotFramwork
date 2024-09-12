*** Settings ***
Documentation     Implementation Keywords for Purchase Service
Library           Libraries.MicroServices.PurchaseService

*** Variables ***

*** Keywords ***
Get All Entitlements For A customer    #USED
    [Documentation]  This keyword returns all the entitled products for a customer
    ${response}    Run Keyword    Get Entitlements    ${LAB_CONF}    customer_id=${CUSTOMER_ID}
    [Return]    ${response}
