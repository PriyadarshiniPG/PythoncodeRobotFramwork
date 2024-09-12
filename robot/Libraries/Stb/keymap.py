"""
RCU Keymap
Keys are listed by ascending key-code
To discover key-codes use 'journalctl -f | grep KeyCode'
"""

KEY_MAP = {
    '0': '30',
    '1': '31',
    '2': '32',
    '3': '33',
    '4': '34',
    '5': '35',
    '6': '36',
    '7': '37',
    '8': '38',
    '9': '39',
    'TEXT': '60',
    'PROFILE': '6e',
    'POWER': '80',
    'UP': '81',
    'DOWN': '82',
    'LEFT': '83',
    'RIGHT': '84',
    'OK': '85',
    'CHANNELUP': '88',
    'CHANNELDOWN': '89',
    'VOLUP': '8a',
    'VOLDOWN': '8b',
    'MUTE': '8c',
    'GUIDE': '8d',
    'INFO': '8e',
    'PAGEUP': '90',
    'PAGEDOWN': '91',
    'YELLOW': '92',
    'BLUE': '93',
    'RED': '94',
    'BACK': '95',
    'FRWD': '97',  # ambiguous
    'FFWD': '98',
    'PLAY': '99',  # original
    'PLAY-PAUSE': '9b',
    'STOP': '9a',
    'PAUSE': '9b',
    'PVR': '9c',  # original
    'REC': '9c',  # original
    'UPC': '9e',
    'GREEN': '9f',
    'HELP': 'a1',
    'INTERACTIVE': 'a6',
    'CONTEXT': '6D',
    'MENU': 'c0',
    'TV': 'c1',
    'LIVETV': 'd1',
    'DVR': 'd2',
    'VOD': 'd3',
    'VOICE': '64'
}
