*** Settings ***
Documentation     Resources required for CMM test cases.
Resource          ../../../Keywords/CPE/Common/Common.robot
Resource          ../../../Keywords/CPE/PA-04_User_Interface/ChannelBar_Keywords.robot
Resource          ../../../Keywords/CPE/PA-10_Player/Player_Keywords.robot
Resource          ../../../Keywords/mservice.basic.robot
Resource          ../../../Keywords/xap.basic.robot
Resource          ../../../Keywords/CPE/PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../../../Keywords/CPE/PA-26_Applications/Apps_Keywords.robot
Resource          ../../../Keywords/CPE/PA-19_Cloud_Recordings/PVR_Keywords.robot
Resource          ../../../Keywords/CPE/PA-19_Cloud_Recordings/PVR_Implementation.robot
Resource          ../../../Keywords/CPE/PA-15_VOD/OnDemand_Keywords.robot
Resource          ../../../Keywords/CPE/PA-15_VOD/Saved_Keywords.robot
Resource          ../../../Keywords/meta.robot
Resource          ../../../Keywords/CPE/PA-11_Local_Recordings/Local_Recordings_Keywords.robot
Resource          ../../../Keywords/CPE/PA-02_Stability_and_Performance/Performance_Bootup.robot
Resource          ../../../Keywords/MicroServices/RecordingService/RecordingService_Keywords.robot
Resource          ../../../Keywords/CPE/PA-02_Stability_and_Performance/Stability_Player_Implementation.robot
#Library           ../../../Libraries/Backend/Traxis/
#Library           Libraries.MicroServices.RecordingService
Resource          ../../../Keywords/CPE/PA-14_RCU/VirtualKeyboard_Keywords.robot
Resource          ../../../Keywords/CPE/PA-20_Search/Search_Keywords.robot
Resource          ../../../Keywords/MicroServices/VodService/VodService_Keywords.robot
Resource          ../../../Keywords/CPE/RedRat/RedRat_Keywords.robot
#Library           ../../../Libraries/MicroServices/LinearService
Library           ../../../Libraries/CustomLogger.py
Library           ../../../Libraries/Report/section_map.py

