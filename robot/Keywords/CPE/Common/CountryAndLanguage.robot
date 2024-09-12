*** Settings ***
Documentation     Keywords related to country and language settings
Library    OperatingSystem

*** Keywords ***
Initalize variables for colour    #USED
    [Arguments]    ${country}=NOT_NEED_IT
    [Documentation]    Initialize variables specific to country palette, eg colour code
    ...    based on https://wikiprojects.upc.biz/display/HZN4S5/Colour+Palette
    ${palette}    Get Data Via Testtools    ${STB_IP}    ${CPE_ID}    /locale/palettes/current    ${XAP}
    ${highlight_color_name}    Set Variable    ${palette['HighlightColorName']}
    ${full_opacity_blueSteel}    Set Variable    ${palette['BlueSteel']}
    ${full_opacity_nakatomi}    Set Variable    ${palette['Nakatomi']}
    ${full_opacity_polarBear}    Set Variable    ${palette['PolarBear']}
    set suite variable    ${INTERACTION_COLOUR_NAME}    ${highlight_color_name}
    set suite variable    ${INTERACTION_COLOUR}    ${full_opacity_blueSteel}
    set suite variable    ${HIGHLIGHTED_OPTION_COLOUR}    ${full_opacity_nakatomi}
    set suite variable    ${HIGHLIGHTED_NAVIGATION_COLOUR}    ${palette['FocusedText']}

The CPE is installed in
    [Arguments]    ${country}
    [Documentation]    Change country code via Application Services
    set suite variable    ${COUNTRY}    ${country}
    I set the country code to    ${country}

Read current country code    #USED
    [Documentation]    Change country code via Application Services
    ${current_country_code}    get country code from stb
    ${COUNTRY}    convert to lowercase    ${current_country_code}
    set suite variable    ${COUNTRY}    ${COUNTRY}
    log to console    Current COUNTRY_CODE: ${COUNTRY}
    [Return]    ${COUNTRY}

get country code from stb    #USED
    [Documentation]    Keyword for getting country code from STB
    ${current_country_code}    Get application service setting    cpe.country
#    ${current_country_code}    get country code from stb via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${current_country_code}

Make sure contry code is set to
    [Arguments]    ${country}
    [Documentation]    Keyword to check that STB is set to given country code or not
    Check that STB contry code is set to    ${country}
    Initalize variables for colour

I set the country code to
    [Arguments]    ${country}
    [Documentation]    Keyword for setting country code on STB
    ${country}    convert to lowercase    ${country}
    ${current_country_code}    Read current country code
    run keyword if    '${current_country_code}' == '${country}'    Run Keywords    Initalize variables for colour
    ...    AND    return from keyword
    wait until keyword succeeds    3times    5 sec    set country code    ${country}
    Make sure contry code is set to    ${country}
    Power cycle to apply localization settings    ${country}

set country code
    [Arguments]    ${country}
    [Documentation]    Keyword for setting country code on STB
    set country code via as    ${STB_IP}    ${CPE_ID}    ${country}    xap=${XAP}

I set osd language from appservices to ${lang}        #USED
    [Documentation]    Changes language through app services to given language
    ${lang}    convert to lowercase    ${lang}
    ${osd_lang}    get application service setting    profile.osdLang
    run keyword if    '${osd_lang}' == '${lang}'    Initalize ui variables for menu language    ${osd_lang}
    return from keyword if    '${osd_lang}' == '${lang}'
    log to console    \nChanging OSD Language(UI) from ${osd_lang} to ${lang}
    ${osd_lang}    Set value via application services    profile.osdLang    ${lang}
    Run keyword if    '${osd_lang}' != '${lang}'    fail    set new osd language through appservices failed
    Initalize ui variables for menu language    ${osd_lang}

Initalize ui variables for menu language    #USED
    [Arguments]    ${lang}
    [Documentation]    Initializes dictionary values based on a language
    # TODO - IMPROVE MOVE THOSE FROM TRANSLATION FILES using 
    # TODO - COUNTRY_CODE, OSD_LANGUAGE and CPE_VERSION to determinate TRANSLATION file to use
#    Initialize trasnlations variables
    Run keyword if    '${lang}' == 'en'    Initialize english variables
    ...    ELSE IF    '${lang}' == 'nl'    Initialize dutch variables

Initialize dutch variables    #USED
    [Documentation]    Initializes variables for Dutch
    # TODO - MOVE THOSE FROM TRANSLATION FILES [Initialize trasnlations variables]
    set suite variable    ${DIC_PLEASE_ENTER_YOUR_PIN_CODE}    Voer je pincode in
    set suite variable    ${DIC_MANAGE_LOCKED_CHANNELS}    Beheer geblokkeerde zenders
    set suite variable    ${DIC_CLEAR_LIST}    LIJST OPSCHONEN
    set suite variable    ${DIC_UNLOCK_BANNER_1}    om deze zender te bekijken
    set suite variable    ${DIC_UNLOCK_BANNER_2}    om dit programma te kijken
    set suite variable    ${DIC_UNLOCK_BANNER_3}    Om dit programma te ontgrendelen
    set suite variable    ${DIC_LOCKED_CHANNEL}    Geblokkeerde zender
    set suite variable    ${DIC_ADULT_PROGRAMME}    Erotisch programma
    set suite variable    ${DIC_ADULT_CHANNEL}    Erotiek zender
    set suite variable    ${DIC_PREFERENCES}    VOORKEUREN
    set suite variable    ${DIC_FAVOURITE_CHANNELS}    Favoriete zenders
    set suite variable    ${DIC_CHANGE_PIN}    Wijzig pincode
    set suite variable    ${DIC_PRIMARY_VIDEO_OUTPUT}    Video-uitgang
    set suite variable    ${DIC_NETWORK_SUMMARY}    Netwerkoverzicht
    set suite variable    ${DIC_VISIT_OUR_WEBSITE}    Hulp nodig?
    set suite variable    ${DIC_STANDBY_TIMER}    Stand-by timer
    set suite variable    ${DIC_PARENTAL_CONTROL}    OUDERLIJK TOEZICHT
    set suite variable    ${DIC_SYSTEM}    SYSTEEM

Initialize english variables    #USED
    [Documentation]    Initializes variables for English
    # TODO - MOVE THOSE FROM TRANSLATION FILES [Initialize trasnlations variables]
    set suite variable    ${DIC_PLEASE_ENTER_YOUR_PIN_CODE}    Please enter your PIN code
    set suite variable    ${DIC_MANAGE_LOCKED_CHANNELS}    Manage locked channels
    set suite variable    ${DIC_CLEAR_LIST}    CLEAR LIST
    set suite variable    ${DIC_UNLOCK_BANNER_1}    to unlock this channel
    set suite variable    ${DIC_UNLOCK_BANNER_2}    to view this channel
    set suite variable    ${DIC_UNLOCK_BANNER_3}    to unlock this programme
    set suite variable    ${DIC_SUBSCRIBE_BANNER}    to subscribe to this channel
    set suite variable    ${DIC_LOCKED_CHANNEL}    DIC_LOCKED_CHANNEL
    set suite variable    ${DIC_ADULT_PROGRAMME}    Adult programme
    set suite variable    ${DIC_ADULT_CHANNEL}    18+ channel
    set suite variable    ${DIC_PREFERENCES}    PREFERENCES
    set suite variable    ${DIC_FAVOURITE_CHANNELS}    Favourite channels
    set suite variable    ${DIC_CHANGE_PIN}    Change PIN
    set suite variable    ${DIC_PRIMARY_VIDEO_OUTPUT}    Primary video output
    set suite variable    ${DIC_NETWORK_SUMMARY}    Network summary
    set suite variable    ${DIC_VISIT_OUR_WEBSITE}    Visit our website at www.upc.com/help
    set suite variable    ${DIC_STANDBY_TIMER}    Standby timer
    set suite variable    ${DIC_PARENTAL_CONTROL}    PARENTAL CONTROL
    set suite variable    ${DIC_SYSTEM}    SYSTEM

Initialize trasnlations variables    #ON_DEVELOPMENT
    [Arguments]    ${CPE_VERSION}=${CPE_VERSION}    ${OSD_LANGUAGE}=${OSD_LANGUAGE}    ${COUNTRY}=${COUNTRY}
    [Documentation]    Initializes variables for English
    # TODO - ON DEVELOPMENT
    #Example file path location: e2e_si_automation\robot\Translations\073-af\en-nl.json
    ${translation_json_file}    set variable    ./Translations/${CPE_VERSION}/${OSD_LANGUAGE}-${COUNTRY}.json
    log to console    \nTranslation_json_file: ${translation_json_file}
    ${translation_json}    OperatingSystem.Get file    ${translation_json_file}
    log to console    \ntranslation_json: ${translation_json}
    ${translation_object}    Evaluate    json.loads('''${translation_json}''')    json
    log to console    \ntranslation_object[DIC_ETHERNET_STATUS]: ${translation_object["DIC_ETHERNET_STATUS"]}
    log to console    \ntranslation_object[DIC_PLEASE_ENTER_YOUR_PIN_CODE]: ${translation_object["DIC_PLEASE_ENTER_YOUR_PIN_CODE"]}
    set suite variable    ${DIC_PLEASE_ENTER_YOUR_PIN_CODE}    ${translation_object["DIC_PLEASE_ENTER_YOUR_PIN_CODE"]}
    set suite variable    ${DIC_MANAGE_LOCKED_CHANNELS}    ${translation_object["DIC_LOCKED_HEADER"]}    #Manage locked channels
    set suite variable    ${DIC_CLEAR_LIST}    channels LIST
    set suite variable    ${DIC_UNLOCK_BANNER_1}    to unlock this channel
    set suite variable    ${DIC_UNLOCK_BANNER_2}    to view this channel
    set suite variable    ${DIC_UNLOCK_BANNER_3}    to unlock this programme    #DIC_RC_CUE_UNLOCK_PROGRAM
    set suite variable    ${DIC_SUBSCRIBE_BANNER}    to subscribe to this channel
    set suite variable    ${DIC_LOCKED_CHANNEL}    DIC_LOCKED_CHANNEL
    set suite variable    ${DIC_ADULT_PROGRAMME}    ${translation_object["DIC_ADULT_PROGRAMME"]}    #Adult programme
    set suite variable    ${DIC_ADULT_CHANNEL}    18+ channel
    set suite variable    ${DIC_PREFERENCES}    PREFERENCES    #DIC_SETTINGS_SECTION_PREFERNCES
    set suite variable    ${DIC_FAVOURITE_CHANNELS}    Favourite channels    #DIC_SETTINGS_FAVOURITE_CHANNELS_LABEL
    set suite variable    ${DIC_CHANGE_PIN}    Change PIN
    set suite variable    ${DIC_PRIMARY_VIDEO_OUTPUT}    Primary video output
    set suite variable    ${DIC_NETWORK_SUMMARY}    Network summary
    set suite variable    ${DIC_VISIT_OUR_WEBSITE}    Visit our website at www.upc.com/help
    set suite variable    ${DIC_STANDBY_TIMER}    Standby timer
    set suite variable    ${DIC_PARENTAL_CONTROL}    PARENTAL CONTROL
    set suite variable    ${DIC_SYSTEM}    SYSTEM

I set the country code and osd language to
    [Arguments]    ${country}    ${osd_language}
    [Documentation]    set the country code and osd language via application services
    The CPE is installed in    ${country}
    I set osd language from appservices to ${osd_language}

Make sure OSD Language is set to
    [Arguments]    ${given_osd_language}
    [Documentation]    Keyword that tries to set osd language via application services
    ...    The reboot_required flag should be True if given osd language is different from the current osd language
    ${given_osd_language}    convert to lowercase    ${given_osd_language}
    ${current_osd_lang}    get application service setting    profile.osdLang
    return from keyword if    '${given_osd_language}'=='${current_osd_lang}'
    wait until keyword succeeds    3times    1 sec    set application services setting    profile.osdLang    ${given_osd_language}
    ${current_osd_lang}    get application service setting    profile.osdLang
    should be equal as strings    ${current_osd_lang}    ${given_osd_language}    OSD language not set

Make sure country code is set to
    [Arguments]    ${given_country_code}
    [Documentation]    Keyword that tries to set the country code via application services.
    ...    The reboot_required flag should be True if given country code is different from the current country code
    ${given_country_code}    convert to lowercase    ${given_country_code}
    ${current_country_code}    Read current country code
    return from keyword if    '${given_country_code}'=='${current_country_code}'
    set suite variable    ${reboot_for_localization}    True
    wait until keyword succeeds    3times    1 sec    set country code    ${given_country_code}
    ${new_country_code}    Read current country code
    should match    '${given_country_code}'    '${new_country_code}'

Make sure that localization is correct        #NOT_USED
    [Arguments]    ${country}=${COUNTRY}    ${language_code}=${OSD_LANGUAGE}
    [Documentation]    Keyword to make sure that STB is running with country code BE and OSD language English
    ...    If the current country code or OSD language is different from the the given one, then keyword set it via
    ...    Application Serivce and reboot the set-top box and then verify the changes
    set suite variable    ${reboot_for_localization}    False
    ${country}    convert to lowercase    ${country}
    Make sure country code is set to    ${country}
    Make sure OSD Language is set to    ${language_code}
    Initalize variables for colour
    Initalize ui variables for menu language    ${language_code}
    run keyword if    '${reboot_for_localization}'=='True'    Power cycle to apply localization settings    ${country}    ${language_code}

Check that STB contry code is set to
    [Arguments]    ${given_country_code}
    [Documentation]    Keyword to check that STB is set to given country code or not
    ${given_country_code}    convert to lowercase    ${given_country_code}
    ${current_country_code}    Read current country code
    should be equal    ${current_country_code}    ${given_country_code}    Given country code    is not matching with the current country code    ignore_case=True
