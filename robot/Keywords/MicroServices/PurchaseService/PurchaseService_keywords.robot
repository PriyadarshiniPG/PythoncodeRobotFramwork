*** Settings ***
Documentation     Implementation Keywords for PersonalizationService
Resource          ./PurchaseService_Implementation.robot

*** Variables ***

*** Keywords ***
Get List Of Entitlement IDs For A Customer  #USED
    [Documentation]    This keyword returns the list of ID of products subscribed for a customer
    ${response}    Get All Entitlements For A customer

    ${reponse_json}    Set Variable    ${response.json()}
    ${entitlements_list}    Set Variable    ${reponse_json['entitlements']}
    @{entitlements_id_list}    Create List
    :FOR    ${channel}    IN    @{entitlements_list}
    \    ${id}    Evaluate    ${channel}.get("id")
    \    Append To List    ${entitlements_id_list}    ${id}
    Log    ${entitlements_id_list}
    [Return]    ${entitlements_id_list}