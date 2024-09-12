VOD_NAV_MAP = {
    "SEARCH": ["X"],
    "DISCOVER": ["DISCOVER", "HIGHLIGHTS", "ONTDEK"],
    "MOVIES": ["MOVIES", "FILME", "FILMS", "VIRGIN MOVIES", "MYPRIME"],
    "SERIES": ["SERIES", "TVSERIES", "BOX SETS", "BOXSETS"],
    "SHOWS": ["SHOWS"],
    "KIDS": ["KIDS", "KINDER"],
    "RENT": ["RENT", "STORE", "ALACARTE", "ONEDEMAND", "RENTAL", "A LA CARTE", "HUURFILMS", "PATHÉ THUIS"],
    "PROVIDERS": ["PROVIDERS", "CATCH UP","CHANNELS", "ZENDERS", "STARZPLAY","LIONSGATE+"],
    "EROTIC": ["EROTIC", "PASSION"],
    "SKYCINEMA": ["SKY CINEMA & SPORTS"],
    "CATEGORY": ["CATEGORIES"],
    "PLAYSPORTS": ["PLAYSPORTS", "SPORT"],
    "BINNENKORT": ["BINNENKORT"],
    "ADDITIONAL": ["DE MOL", "PLAY SPORTS"]
}

CMM_NAV_MAP = {
    "SEARCH": ["X"],
    "TV & REPLAY": ["TV & REPLAY", "GUIDE", "DIC_MAIN_MENU_TV_TV"],
    "VOD": ["MOVIES & SERIES", "BOX SETS & MOVIES", "DIC_MAIN_MENU_MOVIES_AND_SERIES"],
    "SAVED": ["SAVED", "DIC_MAIN_MENU_SAVED","DIC_MAIN_MENU_RECORDINGS","RECORDINGS"],
    "TV APPS": ["TV APPS", "APPS", "DIC_MAIN_MENU_APPS"],
    "SETTINGS": ["W"],
    "REPLAY TV": ["REPLAY TV", "CATCH UP", "DIC_MAIN_MENU_TV_REPLAY"],
    "PROFILE": ["ǥ","Ǥ"],
    "HOME": ["HOME","DIC_MAIN_MENU_HOME"]

}

TVAPPS_NAV_MAP = {
    "SEARCH": ["X"],
    "DISCOVER": ["DISCOVER","FOR YOU"],
    "APP STORE": ["APP STORE","ALL APPS", "APPS", "APPSTORE"]
}

SETTINGS_NAV_MAP = {
    "PROFILES": ["PROFILES"],
    "PARENTAL CONTROL": ["PARENTAL CONTROL","PARENTAL CONTROLS"],
    "SYSTEM": ["SYSTEM"],
    "SOUND & IMAGE": ["SOUND & IMAGE", "AUDIO & VIDEO", "IMAGE AND SOUND"],
    "NETWORK": ["NETWORK"],
    "INFO": ["INFO"],
    "ACCESSIBILITY": ["ACCESSIBILITY"]
}

SAVED_NAV_MAP = {
    "SEARCH": ["X"],
    "RECORDINGS": ["RECORDINGS"],
    "WATCHLIST": ["WATCHLIST"],
    "CONTINUE WATCHING": ["CONTINUE WATCHING"],
    "RENTED": ["RENTED"]
}


lookup = {
     "VOD": VOD_NAV_MAP,
     "CMM": CMM_NAV_MAP,
     "TVAPPS": TVAPPS_NAV_MAP,
     "SETTINGS" : SETTINGS_NAV_MAP,
     "SAVED": SAVED_NAV_MAP
}

def get_action_for_section_navigation(context, label):
    context_lookup = lookup[context]
    for key, value in context_lookup.items():
        if label.upper().strip() in value:
            return key

def get_title_from_ordereddict(odict):
    title = odict['title'] if 'title' in odict else 'None'
    title = title.replace('"','\\"')
    return title
