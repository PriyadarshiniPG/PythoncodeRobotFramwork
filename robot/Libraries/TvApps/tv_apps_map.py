APP_ID_MAP = {
    "Videoland": "com.videoland.ziggo",
    "NPO": "com.twentyfouri.npo",
    "YouTube": "com.libertyglobal.app.youtube",
    "Netflix": "com.libertyglobal.app.netflix",
    "Netflix 300": "com.libertyglobal.app.netflix",
    "Film1": "com.wearetriple.app.Film1",
    "Al Jazeera" : "com.metrological.app.AljazeeraV2",
    "BBC iPlayer" : "com.bbc.app.iplayer",
    "Tetris" : "com.gametree.tv.Tetris",
    "Vimeo" : "com.metrological.app.VimeoRelease",
    "Virtuagym" : "com.libertyglobal.app.VirtuaGym",
    "XITE | music videos" : "nl.xite.myxite",
    "prime video" : "com.libertyglobal.app.primevideo",
    "Prime Video" : "com.libertyglobal.app.primevideo",
    "Sky Sport" : "com.sky.app.sky",
    "Stingray Music" : "com.metrological.app.StingrayMusic",
    "MySports Shop" : "com.libertyglobal.app.MySportsCH2",
    "TV Shop" : "com.telenet.app.tvshop",
    "Sky Show" : "com.sky.app.show"
}

APP_STORE_ID_MAP = {
    "nl_eos": "APP STORE",
    "nl_eosv2": "APP STORE",
    "nl_selene": "APP STORE",
	"nl_apollo": "APP STORE",
    "gb_eos": "ALL APPS",
    "gb_bento": "ALL APPS",
    "ie_eos": "APPS",
    "ie_apollo": "APPS",
    "pl_apollo": "APP STORE",
    "ch_eos": "APPSTORE",
    "ch_eosv2": "APPSTORE",
    "ch_apollo": "APPSTORE",
    "be_eos": "APPS",
    "be_eosv2": "APPS"
}

def get_app_id_for_tv_app(app_name):
    return APP_ID_MAP.get(app_name)

def get_app_store_id_for_country(country_code):
    return APP_STORE_ID_MAP.get(country_code.lower())