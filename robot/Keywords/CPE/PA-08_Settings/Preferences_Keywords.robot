*** Settings ***
Documentation     Preferences keywords
Resource          ../PA-08_Settings/Preferences_Implementation.robot

*** Keywords ***
I open 'Add channels' through Favourite channels
    [Documentation]    Favourites: Selects 'Add channels' through Favorite Channels option and channel list is shown
    I focus 'Add channels' for Favourites
    I Press    OK

I open 'Add channels' for Locked    #USED
    [Documentation]    Opens 'Add channels' through CHANNEL LOCKING
    I focus 'Add channels' for Locked
    I Press    OK
    Add Channels is shown for Locked

I set menu language of the stb to ${lang}
    [Documentation]    to set the default menu language of stb through preference settings
    ${lang}    convert to lowercase    ${lang}
    ${current_menu_lang}    Get current menu language
    Run keyword unless    '${current_menu_lang}' == '${${lang}}'    I set to ${${lang}} in Menu Language window
