*** Settings ***
Resource          ../PA-05_Linear_TV/Tuner_Implementation.robot

*** Keywords ***
I open Linear TV
    [Documentation]    This keyword tunes to a free channel and checks the content
    linear tv is shown
