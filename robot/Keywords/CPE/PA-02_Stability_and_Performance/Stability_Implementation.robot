*** Settings ***
Documentation     Stability keyword implementation definitions
Library           SSHLibrary
Library           robot.libraries.DateTime
Resource          ../Common/Common.robot
Resource          ../PA-17_Auth_Trans/Auth_Trans_Keywords.robot
Resource          ../PA-19_Cloud_Recordings/PVR_Keywords.robot
Resource          ../PA-11_Local_Recordings/Local_Recordings_Keywords.robot
Resource          ./Stability_Common.robot
Resource          ./Stability_Fixtures.robot
Resource          ./Stability_Apps_Implementation.robot
Resource          ./Stability_LinearTV_Implementation.robot
Resource          ./Stability_Player_Implementation.robot
Resource          ./Stability_Recordings_Implementation.robot
Resource          ./Stability_VOD_Implementation.robot
Resource          ./Reliability_Keywords.robot
Resource          ./Stress_implementation.robot
