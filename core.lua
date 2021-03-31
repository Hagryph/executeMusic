local _, L = ...
executeMusic = {}

local shortcut = "em"
local musicEnabled = GetCVarBool("Sound_EnableMusic")
local soundEnabled = GetCVarBool("Sound_EnableSFX")
local lang = GetLocale()
local LDB = LibStub( "LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local loadingBar = LibStub("LibCandyBar-3.0")
local texture = "interface/glues/loadingbar/loading-barfill.blp"
local emMI
local minimapInfo
local soundType = {
    SOUND = 1,
	MUSIC = 2,		
    CUSTOM = 3
}
local waitUntil = math.huge
local waitFrame
local uiUpdater
local autoplayFavorite = false
local autoplay = false
local soundId
local autoplayList = {}
local currentAutoplayPlaylist
local autoplaySize = 0
local autoplayPosition = 0
local currentTrack = ""
local currentTrackId = ""
local nextSongNumber = 0
local queued = 0
local queuedSongs = {}
local queueUp = false
local shown = {}
local f = {}
local errorFrame
local miniUi
local update = false
local textMU
local searchBox
local buttons = {}
local buttonsF = {}
local buttonsB = {}
local buttonsAT = {}
local buttonsD = {}
local buttonLists
local buttonCancelLists
local buttonFavorite	
local buttonBlacklist
local buttonAP
local buttonAPF
local buttonAPN
local buttonAddPl
local buttonPause
local songDurationBar
local paused = false
local notResumable = true
local matches = {}
local start = {}
local ending = {}
local number = {}
number[1] = 0
number[2] = 0
local size = 15
local titlesizeextra = 5
local showFavorites = false
local showBlacklist = false
local showPlaylists = false
local playlistMenu
local showPlaylist
local createPlaylistOngoing = false
local addTrackOngoing = false
local trackToAdd
local addCustomTrackOngoing = false
local strings = {}
local stringsC = {}
local errorString
local editBox = {}
local searched
local searchString
local length = {}
local sounds = {
	["murloc"] = {
		["sound"] = 416,
		["description"] = "Mglrlrlrlrlrl!",
		["type"] = soundType.SOUND,
		["length"] = 1
	},
	["grats"] = {
		["sound"] =		888,
		["description"] = "Grats!",
		["type"] = soundType.SOUND,
		["length"] = 4
	},
	["main theme"] = {
		["sound"] = 53223,
		["description"] = "WoW Main Theme",
		["type"] = soundType.MUSIC,
		["length"] = 161
	},
	["river"] = {
		["sound"] = 1113,
		["description"] = "River sound",
		["type"] = soundType.SOUND,
		["length"] = 35
	},
	["darnassus intro"] = {
		["sound"] = 53183,
		["description"] = "Darnassus Intro",
		["type"] = soundType.MUSIC,
		["length"] = 39
	},
	["darnassus"] = {
		["sound"] = 53184,
		["description"] = "Darnassus",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["darnassus 2"] = {
		["sound"] = 53185,
		["description"] = "Darnassus 2",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["darnassus 3"] = {
		["sound"] = 53186,
		["description"] = "Darnassus 3",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["darnassus druidgrove"] = {
		["sound"] = 53187,
		["description"] = "Darnassus Druid Grove",
		["type"] = soundType.MUSIC,
		["length"] = 44
	},
	["darnassus warriorterrace"] = {
		["sound"] = 53188,
		["description"] = "Darnassus Warrior Terrace",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["gnomeregan"] = {
		["sound"] = 53189,
		["description"] = "Gnomeregan",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["gnomeregan02"] = {
		["sound"] = 53190,
		["description"] = "Gnomeregan02",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["ironforge intro"] = {
		["sound"] = 53191,
		["description"] = "Ironforge Intro",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["ironforge"] = {
		["sound"] = 53192,
		["description"] = "Ironforge",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["ironforge 2"] = {
		["sound"] = 53193,
		["description"] = "Ironforge 2",
		["type"] = soundType.MUSIC,
		["length"] = 50
	},
	["ironforge 3"] = {
		["sound"] = 53194,
		["description"] = "Ironforge 3 (glenn)",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["ironforge 4"] = {
		["sound"] = 53195,
		["description"] = "Ironforge 4",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["ironforge tinkertownintro"] = {
		["sound"] = 53196,
		["description"] = "Ironforge Tinkertown Intro Moment",
		["type"] = soundType.MUSIC,
		["length"] = 51
	},
	["ogrimmar moment"] = {
		["sound"] = 53197,
		["description"] = "Ogrimmar Moment",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["ogrimmar zone"] = {
		["sound"] = 53198,
		["description"] = "Ogrimmar Zone",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["ogrimmar02 moment"] = {
		["sound"] = 53199,
		["description"] = "Ogrimmar 2 Moment",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["ogrimmar02 zone"] = {
		["sound"] = 53200,
		["description"] = "Ogrimmar 2 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["ogrimmar intro"] = {
		["sound"] = 53201,
		["description"] = "Ogrimmar Intro Moment",
		["type"] = soundType.MUSIC,
		["length"] = 40
	},
	["stormwind moment"] = {
		["sound"] = 53202,
		["description"] = "Stormwind Moment",
		["type"] = soundType.MUSIC,
		["length"] = 54
	},
	["stormwind02 moment"] = {
		["sound"] = 53203,
		["description"] = "Stormwind 2 Moment",
		["type"] = soundType.MUSIC,
		["length"] = 35
	},
	["stormwind03 moment"] = {
		["sound"] = 53204,
		["description"] = "Stormwind 3 Moment",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["stormwind04 zone"] = {
		["sound"] = 53205,
		["description"] = "Stormwind 4 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["stormwind05 zone"] = {
		["sound"] = 53206,
		["description"] = "Stormwind 5 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["stormwind06 zone"] = {
		["sound"] = 53207,
		["description"] = "Stormwind 6 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["stormwind07 zone"] = {
		["sound"] = 53208,
		["description"] = "Stormwind 7 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["stormwind08 zone"] = {
		["sound"] = 53209,
		["description"] = "Stormwind 8 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 77
	},
	["stormwind highseas"] = {
		["sound"] = 53210,
		["description"] = "Stormwind Highseas Moment",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["stormwind intro"] = {
		["sound"] = 53211,
		["description"] = "Stormwind Intro Moment",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["thunderbluff intro"] = {
		["sound"] = 53212,
		["description"] = "Thunderbluff Intro",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["thunderbluff"] = {
		["sound"] = 53213,
		["description"] = "Thunderbluff",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["thunderbluff 02"] = {
		["sound"] = 53214,
		["description"] = "Thunderbluff 2",
		["type"] = soundType.MUSIC,
		["length"] = 116
	},
	["thunderbluff 03"] = {
		["sound"] = 53215,
		["description"] = "Thunderbluff 3",
		["type"] = soundType.MUSIC,
		["length"] = 121
	},
	["undercity zone"] = {
		["sound"] = 53216,
		["description"] = "Undercity Zone",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["undercity02 zone"] = {
		["sound"] = 53217,
		["description"] = "Undercity 2 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["undercity03 zone"] = {
		["sound"] = 53218,
		["description"] = "Undercity 3 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["undercity intro"] = {
		["sound"] = 53219,
		["description"] = "Undercity Intro Moment",
		["type"] = soundType.MUSIC,
		["length"] = 28
	},
	["bc maintheme"] = {
		["sound"] = 53220,
		["description"] = "Burning Crusade Main",
		["type"] = soundType.MUSIC,
		["length"] = 226
	},
	["bc credits"] = {
		["sound"] = 53221,
		["description"] = "Burning Crusade Credits Lament of the Highborne",
		["type"] = soundType.MUSIC,
		["length"] = 171
	},
	["wotlk maintitle"] = {
		["sound"] = 53222,
		["description"] = "Wrath of the Lich King main Title",
		["type"] = soundType.MUSIC,
		["length"] = 544
	},
	["wotlk maintheme"] = {
		["sound"] = 53223,
		["description"] = "Wrath of the Lich King main",
		["type"] = soundType.MUSIC,
		["length"] = 161
	},
	["angelic"] = {
		["sound"] = 53224,
		["description"] = "Angelic",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["battle"] = {
		["sound"] = 53225,
		["description"] = "Battle",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["battle02"] = {
		["sound"] = 53226,
		["description"] = "Battle 2",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["battle03"] = {
		["sound"] = 53227,
		["description"] = "Battle 3",
		["type"] = soundType.MUSIC,
		["length"] = 27
	},
	["battle04"] = {
		["sound"] = 53228,
		["description"] = "Battle 4",
		["type"] = soundType.MUSIC,
		["length"] = 36
	},
	["battle05"] = {
		["sound"] = 53229,
		["description"] = "Battle 5",
		["type"] = soundType.MUSIC,
		["length"] = 44
	},
	["battle06"] = {
		["sound"] = 53230,
		["description"] = "Battle 6",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["gloomy"] = {
		["sound"] = 53231,
		["description"] = "Gloomy",
		["type"] = soundType.MUSIC,
		["length"] = 36
	},
	["gloomy02"] = {
		["sound"] = 53232,
		["description"] = "Gloomy 2",
		["type"] = soundType.MUSIC,
		["length"] = 39
	},
	["guldansentrance"] = {
		["sound"] = 53233,
		["description"] = "Guldans Entrance",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["haunted"] = {
		["sound"] = 53234,
		["description"] = "Haunted",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["haunted02"] = {
		["sound"] = 53235,
		["description"] = "Haunted 2",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["magic moment"] = {
		["sound"] = 53236,
		["description"] = "Magic Moment",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["magic zone"] = {
		["sound"] = 53237,
		["description"] = "Magic Zone",
		["type"] = soundType.MUSIC,
		["length"] = 33
	},
	["magic zone2"] = {
		["sound"] = 53238,
		["description"] = "Magic Zone 2",
		["type"] = soundType.MUSIC,
		["length"] = 39
	},
	["ahnqiraj intro"] = {
		["sound"] = 53239,
		["description"] = "Ahn'qiraj Intro",
		["type"] = soundType.MUSIC,
		["length"] = 143
	},
	["mystery zone"] = {
		["sound"] = 53240,
		["description"] = "Mystery Zone",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["mystery02 zone"] = {
		["sound"] = 53241,
		["description"] = "Mystery 2 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["mystery03 zone"] = {
		["sound"] = 53242,
		["description"] = "Mystery 3 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["mystery04 zone"] = {
		["sound"] = 53243,
		["description"] = "Mystery 4 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["mystery05 zone"] = {
		["sound"] = 53244,
		["description"] = "Mystery 5 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["mystery06 zone"] = {
		["sound"] = 53245,
		["description"] = "Mystery 6 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["mystery07 zone"] = {
		["sound"] = 53246,
		["description"] = "Mystery 7 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["mystery08 zone"] = {
		["sound"] = 53247,
		["description"] = "Mystery 8 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["mystery09 zone"] = {
		["sound"] = 53248,
		["description"] = "Mystery 9 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["mystery10 zone"] = {
		["sound"] = 53249,
		["description"] = "Mystery 10 Zone",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["sacred"] = {
		["sound"] = 53250,
		["description"] = "Sacred",
		["type"] = soundType.MUSIC,
		["length"] = 16
	},
	["sacred02"] = {
		["sound"] = 53251,
		["description"] = "Sacred 2",
		["type"] = soundType.MUSIC,
		["length"] = 19
	},
	["spooky"] = {
		["sound"] = 53252,
		["description"] = "Spooky Moment",
		["type"] = soundType.MUSIC,
		["length"] = 25
	},
	["swamp"] = {
		["sound"] = 53253,
		["description"] = "Swamp",
		["type"] = soundType.MUSIC,
		["length"] = 34
	},
	["zulgurubvodoo"] = {
		["sound"] = 53254,
		["description"] = "Zul'gurub Vodoo",
		["type"] = soundType.MUSIC,
		["length"] = 84
	},
	["alliance firepole"] = {
		["sound"] = 53255,
		["description"] = "Alliance Firepole",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["darkmoonfaire"] = {
		["sound"] = 53256,
		["description"] = "Darkmoon Faire",
		["type"] = soundType.MUSIC,
		["length"] = 28
	},
	["darkmoonfaire2"] = {
		["sound"] = 53257,
		["description"] = "Darkmoon Faire 2",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["darkmoonfaire3"] = {
		["sound"] = 53258,
		["description"] = "Darkmoon Faire 3",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["darkmoonfaire4"] = {
		["sound"] = 53259,
		["description"] = "Darkmoon Faire 4",
		["type"] = soundType.MUSIC,
		["length"] = 37
	},
	["horde firepole"] = {
		["sound"] = 53260,
		["description"] = "Horde Firepole",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["ahnqiraj exterior"] = {
		["sound"] = 53261,
		["description"] = "Ahn'qiraj exterior",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["ahnqiraj exterior2"] = {
		["sound"] = 53262,
		["description"] = "Ahn'qiraj exterior 2",
		["type"] = soundType.MUSIC,
		["length"] = 84
	},
	["ahnqiraj exterior3"] = {
		["sound"] = 53263,
		["description"] = "Ahn'qiraj exterior 3",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["ahnqiraj exterior4"] = {
		["sound"] = 53264,
		["description"] = "Ahn'qiraj exterior 4",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["ahnqiraj interior"] = {
		["sound"] = 53265,
		["description"] = "Ahn'qiraj Interior",
		["type"] = soundType.MUSIC,
		["length"] = 52
	},
	["ahnqiraj interior2"] = {
		["sound"] = 53266,
		["description"] = "Ahn'qiraj Interior 2",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["ahnqiraj interior3"] = {
		["sound"] = 53267,
		["description"] = "Ahn'qiraj Interior 3",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["ahnqiraj icenterroom"] = {
		["sound"] = 53268,
		["description"] = "Ahn'qiraj Interior Centerroom",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["ahnqiraj iintromain"] = {
		["sound"] = 53269,
		["description"] = "Ahn'qiraj Interior Intro Main",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["ahnqiraj kingroom"] = {
		["sound"] = 53270,
		["description"] = "Ahn'qiraj Kingroom",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["ahnqiraj troom"] = {
		["sound"] = 53271,
		["description"] = "Ahn'qiraj Triangle Room",
		["type"] = soundType.MUSIC,
		["length"] = 23
	},
	["ahnqiraj troom2"] = {
		["sound"] = 53272,
		["description"] = "Ahn'qiraj Triangle Room 2",
		["type"] = soundType.MUSIC,
		["length"] = 17
	},
	["ahnqiraj troom3"] = {
		["sound"] = 53273,
		["description"] = "Ahn'qiraj Triangle Room 3",
		["type"] = soundType.MUSIC,
		["length"] = 15
	},
	["ahnqiraj troom4"] = {
		["sound"] = 53274,
		["description"] = "Ahn'qiraj Triangle Room 4",
		["type"] = soundType.MUSIC,
		["length"] = 19
	},
	["ahnqiraj troom5"] = {
		["sound"] = 53275,
		["description"] = "Ahn'qiraj Triangle Room 5",
		["type"] = soundType.MUSIC,
		["length"] = 31
	},
	["ahnqiraj troom6"] = {
		["sound"] = 53276,
		["description"] = "Ahn'qiraj Triangle Room 6",
		["type"] = soundType.MUSIC,
		["length"] = 20
	},
	["ahnqiraj troom7"] = {
		["sound"] = 53277,
		["description"] = "Ahn'qiraj Triangle Room 7",
		["type"] = soundType.MUSIC,
		["length"] = 17
	},
	["draenei 05"] = {
		["sound"] = 53278,
		["description"] = "Draenei 5",
		["type"] = soundType.MUSIC,
		["length"] = 191
	},
	["draenei 06"] = {
		["sound"] = 53279,
		["description"] = "Draenei 6",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["draenei 08r"] = {
		["sound"] = 53281,
		["description"] = "Draenei 8",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["exodar intro"] = {
		["sound"] = 53282,
		["description"] = "Exodar Intro",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["exodar "] = {
		["sound"] = 53283,
		["description"] = "Exodar",
		["type"] = soundType.MUSIC,
		["length"] = 109
	},
	["exodar 02"] = {
		["sound"] = 53284,
		["description"] = "Exodar 2",
		["type"] = soundType.MUSIC,
		["length"] = 107
	},
	["exodar 03"] = {
		["sound"] = 53285,
		["description"] = "Exodar 3",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["naga "] = {
		["sound"] = 53286,
		["description"] = "Naga",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["naga 02"] = {
		["sound"] = 53287,
		["description"] = "Naga 2",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["naga 03"] = {
		["sound"] = 53288,
		["description"] = "Naga 3",
		["type"] = soundType.MUSIC,
		["length"] = 149
	},
	["naga 04"] = {
		["sound"] = 53289,
		["description"] = "Naga 4",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["naga 05"] = {
		["sound"] = 53290,
		["description"] = "Naga 5",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["owlkin "] = {
		["sound"] = 53291,
		["description"] = "Owlkin",
		["type"] = soundType.MUSIC,
		["length"] = 49
	},
	["owlkin 02"] = {
		["sound"] = 53292,
		["description"] = "Owlkin 2",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["draenei "] = {
		["sound"] = 53293,
		["description"] = "Draenei",
		["type"] = soundType.MUSIC,
		["length"] = 206
	},
	["draenei 02"] = {
		["sound"] = 53294,
		["description"] = "Draenei 2",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["draenei 03"] = {
		["sound"] = 53296,
		["description"] = "Draenei 3",
		["type"] = soundType.MUSIC,
		["length"] = 187
	},
	["draenei 04"] = {
		["sound"] = 53298,
		["description"] = "Draenei 4",
		["type"] = soundType.MUSIC,
		["length"] = 158
	},
	["day barrendry"] = {
		["sound"] = 53299,
		["description"] = "Day Barrendry",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["day barrendry02"] = {
		["sound"] = 53300,
		["description"] = "Day Barrendry 2",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["day barrendry03"] = {
		["sound"] = 53301,
		["description"] = "Day Barrendry 3",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["night barrendry"] = {
		["sound"] = 53302,
		["description"] = "Night Barrendry",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["night barrendry02"] = {
		["sound"] = 53303,
		["description"] = "Night Barrendry 2",
		["type"] = soundType.MUSIC,
		["length"] = 40
	},
	["night barrendry03"] = {
		["sound"] = 53304,
		["description"] = "Night Barrendry 3",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["bt arrival"] = {
		["sound"] = 53305,
		["description"] = "Black Temple Arrival",
		["type"] = soundType.MUSIC,
		["length"] = 163
	},
	["bt arrival3"] = {
		["sound"] = 53307,
		["description"] = "Black Temple Arrival 3",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["bt arrival4"] = {
		["sound"] = 53308,
		["description"] = "Black Temple Arrival 4",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["bt illidari09"] = {
		["sound"] = 53309,
		["description"] = "Black Temple Illidari 9",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["bt illidari"] = {
		["sound"] = 53310,
		["description"] = "Black Temple Illidari",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["bt illidari02"] = {
		["sound"] = 53311,
		["description"] = "Black Temple Illidari 2",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["bt illidari03"] = {
		["sound"] = 53312,
		["description"] = "Black Temple Illidari 3",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["bt illidari04"] = {
		["sound"] = 53313,
		["description"] = "Black Temple Illidari 4",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["bt illidari05"] = {
		["sound"] = 53314,
		["description"] = "Black Temple Illidari 5",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["bt illidari06"] = {
		["sound"] = 53315,
		["description"] = "Black Temple Illidari 6",
		["type"] = soundType.MUSIC,
		["length"] = 29
	},
	["bt illidari07"] = {
		["sound"] = 53316,
		["description"] = "Black Temple Illidari 7",
		["type"] = soundType.MUSIC,
		["length"] = 77
	},
	["bt illidari08"] = {
		["sound"] = 53317,
		["description"] = "Black Temple Illidari 8",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["bt illidari10"] = {
		["sound"] = 53318,
		["description"] = "Black Temple Illidari 10",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["bt illidari11"] = {
		["sound"] = 53319,
		["description"] = "Black Temple Illidari 11",
		["type"] = soundType.MUSIC,
		["length"] = 35
	},
	["bt karabor"] = {
		["sound"] = 53320,
		["description"] = "Black Temple Karabor",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["bt karabor02"] = {
		["sound"] = 53321,
		["description"] = "Black Temple Karabor 2",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["bt karabor03"] = {
		["sound"] = 53322,
		["description"] = "Black Temple Karabor 3",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["bt karabor04"] = {
		["sound"] = 53323,
		["description"] = "Black Temple Karabor 4",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["bt preludeevent"] = {
		["sound"] = 53324,
		["description"] = "Black Temple Pre Lude Event",
		["type"] = soundType.MUSIC,
		["length"] = 253
	},
	["bt reliquary"] = {
		["sound"] = 53325,
		["description"] = "Black Temple Reliquary",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["bt reliquary02"] = {
		["sound"] = 53326,
		["description"] = "Black Temple Reliquary 2",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["bt reliquary03"] = {
		["sound"] = 53327,
		["description"] = "Black Temple Reliquary 3",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["bt reliquary04"] = {
		["sound"] = 53328,
		["description"] = "Black Temple Reliquary 4",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["bt reliquary05"] = {
		["sound"] = 53329,
		["description"] = "Black Temple Reliquary 5",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["bt reliquary06"] = {
		["sound"] = 53330,
		["description"] = "Black Temple Reliquary 6",
		["type"] = soundType.MUSIC,
		["length"] = 125
	},
	["bt reliquary07"] = {
		["sound"] = 53331,
		["description"] = "Black Temple Reliquary 7",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["bt reliquary08"] = {
		["sound"] = 53332,
		["description"] = "Black Temple Reliquary 8",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["bt sanctuary"] = {
		["sound"] = 53333,
		["description"] = "Black Temple Sanctuary",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["bt sanctuary02"] = {
		["sound"] = 53334,
		["description"] = "Black Temple Sanctuary 2",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["bt sanctuary03"] = {
		["sound"] = 53335,
		["description"] = "Black Temple Sanctuary 3",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["bt sanctuary04"] = {
		["sound"] = 53336,
		["description"] = "Black Temple Sanctuary 4",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["bt sanctuary05"] = {
		["sound"] = 53337,
		["description"] = "Black Temple Sanctuary 5",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["bt sanctuary05"] = {
		["sound"] = 53337,
		["description"] = "Black Temple Sanctuary 5",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["bt sanctuary06"] = {
		["sound"] = 53338,
		["description"] = "Black Temple Sanctuary 6",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["bt sanctuary07"] = {
		["sound"] = 53339,
		["description"] = "Black Temple Sanctuary 7",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["bt sanctuary08"] = {
		["sound"] = 53340,
		["description"] = "Black Temple Sanctuary 8",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["bt storm02"] = {
		["sound"] = 53341,
		["description"] = "Black Temple Storm 2",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["bt storm"] = {
		["sound"] = 53342,
		["description"] = "Black Temple Storm",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["bt storm03"] = {
		["sound"] = 53343,
		["description"] = "Black Temple Storm 3",
		["type"] = soundType.MUSIC,
		["length"] = 32
	},
	["bt storm04"] = {
		["sound"] = 53344,
		["description"] = "Black Temple Storm 4",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["bt summit"] = {
		["sound"] = 53345,
		["description"] = "Black Temple Summit",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["bt summit02"] = {
		["sound"] = 53346,
		["description"] = "Black Temple Summit 2",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["bt summit03"] = {
		["sound"] = 53347,
		["description"] = "Black Temple Summit 3",
		["type"] = soundType.MUSIC,
		["length"] = 41
	},
	["bt summit04"] = {
		["sound"] = 53348,
		["description"] = "Black Temple Summit 4",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["bt summit05"] = {
		["sound"] = 53349,
		["description"] = "Black Temple Summit 5",
		["type"] = soundType.MUSIC,
		["length"] = 51
	},
	["bl dryforest"] = {
		["sound"] = 53350,
		["description"] = "Blade's Edge Dry Forest",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["bl dryforest02"] = {
		["sound"] = 53351,
		["description"] = "Blade's Edge Dry Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 127
	},
	["bl dryforest03"] = {
		["sound"] = 53352,
		["description"] = "Blade's Edge Dry Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 131
	},
	["bl general"] = {
		["sound"] = 53353,
		["description"] = "Blade's Edge General",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["bl general02"] = {
		["sound"] = 53354,
		["description"] = "Blade's Edge General 2",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["bl general03"] = {
		["sound"] = 53355,
		["description"] = "Blade's Edge General 3",
		["type"] = soundType.MUSIC,
		["length"] = 158
	},
	["bl general04"] = {
		["sound"] = 53356,
		["description"] = "Blade's Edge General 4",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["bl general05"] = {
		["sound"] = 53357,
		["description"] = "Blade's Edge General 5",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["bl ogre"] = {
		["sound"] = 53358,
		["description"] = "Blade's Edge Ogre",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["bl ogre02"] = {
		["sound"] = 53359,
		["description"] = "Blade's Edge Ogre 2",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["bi nagaintro"] = {
		["sound"] = 53360,
		["description"] = "Bloodmyst Isle Naga Intro",
		["type"] = soundType.MUSIC,
		["length"] = 31
	},
	["bi satyr"] = {
		["sound"] = 53362,
		["description"] = "Bloodmyst Isle Satyr",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["bi satyr03"] = {
		["sound"] = 53364,
		["description"] = "Bloodmyst Isle Satyr 3",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["bi satyr04"] = {
		["sound"] = 53365,
		["description"] = "Bloodmyst Isle Satyr 4",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["bi satyr05"] = {
		["sound"] = 53366,
		["description"] = "Bloodmyst Isle Satyr 5",
		["type"] = soundType.MUSIC,
		["length"] = 143
	},
	["bo day"] = {
		["sound"] = 53367,
		["description"] = "Borean Tundra Day",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["bo day02"] = {
		["sound"] = 53368,
		["description"] = "Borean Tundra Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 101
	},
	["bo day03"] = {
		["sound"] = 53369,
		["description"] = "Borean Tundra Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["bo day04"] = {
		["sound"] = 53370,
		["description"] = "Borean Tundra Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["bo night"] = {
		["sound"] = 53371,
		["description"] = "Borean Tundra Night",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["bo night02"] = {
		["sound"] = 53372,
		["description"] = "Borean Tundra Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 115
	},
	["bo night03"] = {
		["sound"] = 53373,
		["description"] = "Borean Tundra Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["bo night04"] = {
		["sound"] = 53374,
		["description"] = "Borean Tundra Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["bo kaskaladay"] = {
		["sound"] = 53375,
		["description"] = "Borean Tundra Kaskala Day",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["bo kaskaladay02"] = {
		["sound"] = 53376,
		["description"] = "Borean Tundra Kaskala Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["bo kaskalanight"] = {
		["sound"] = 53377,
		["description"] = "Borean Tundra Kaskala Night",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["bo kaskalanight02"] = {
		["sound"] = 53378,
		["description"] = "Borean Tundra Kaskala Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["ct brazenintro"] = {
		["sound"] = 53379,
		["description"] = "Caverns of Time Brazen Intro",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["ct caverns"] = {
		["sound"] = 53380,
		["description"] = "Caverns of Time Caverns",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["ct caverns2"] = {
		["sound"] = 53381,
		["description"] = "Caverns of Time Caverns 2",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["ct caverns3"] = {
		["sound"] = 53382,
		["description"] = "Caverns of Time Caverns 3",
		["type"] = soundType.MUSIC,
		["length"] = 168
	},
	["ct caverns4"] = {
		["sound"] = 53383,
		["description"] = "Caverns of Time Caverns 4",
		["type"] = soundType.MUSIC,
		["length"] = 130
	},
	["ct caverns5"] = {
		["sound"] = 53384,
		["description"] = "Caverns of Time Caverns 5",
		["type"] = soundType.MUSIC,
		["length"] = 151
	},
	["ct caverns6"] = {
		["sound"] = 53385,
		["description"] = "Caverns of Time Caverns 6",
		["type"] = soundType.MUSIC,
		["length"] = 161
	},
	["ct caverns7"] = {
		["sound"] = 53386,
		["description"] = "Caverns of Time Caverns 7",
		["type"] = soundType.MUSIC,
		["length"] = 178
	},
	["ct caverns8"] = {
		["sound"] = 53387,
		["description"] = "Caverns of Time Caverns 8",
		["type"] = soundType.MUSIC,
		["length"] = 139
	},
	["ct caverns9"] = {
		["sound"] = 53388,
		["description"] = "Caverns of Time Caverns 9",
		["type"] = soundType.MUSIC,
		["length"] = 161
	},
	["ct durnholdecellar"] = {
		["sound"] = 53389,
		["description"] = "Caverns of Time Durnholde Cellar",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["ct durnholdecellar2"] = {
		["sound"] = 53390,
		["description"] = "Caverns of Time Durnholde Cellar 2",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["ct durnholdecellar3"] = {
		["sound"] = 53391,
		["description"] = "Caverns of Time Durnholde Cellar 3",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["ct durnholdekeep"] = {
		["sound"] = 53392,
		["description"] = "Caverns of Time Durnholde Keep",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["ct durnholdekeep2"] = {
		["sound"] = 53393,
		["description"] = "Caverns of Time Durnholde Keep 2",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["ct durnholdekeep3"] = {
		["sound"] = 53394,
		["description"] = "Caverns of Time Durnholde Keep 3",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["ct durnholdekeep4"] = {
		["sound"] = 53395,
		["description"] = "Caverns of Time Durnholde Keep 4",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["ct durnholdekeep5"] = {
		["sound"] = 53396,
		["description"] = "Caverns of Time Durnholde Keep 5",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["ct durnholdekeep6"] = {
		["sound"] = 53397,
		["description"] = "Caverns of Time Durnholde Keep 6",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["ct durnholdekeep7"] = {
		["sound"] = 53398,
		["description"] = "Caverns of Time Durnholde Keep 7",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["ct durnholdekeep8"] = {
		["sound"] = 53399,
		["description"] = "Caverns of Time Durnholde Keep 8",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["ct durnholdekeep9"] = {
		["sound"] = 53400,
		["description"] = "Caverns of Time Durnholde Keep 9",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["ct escapedurnintro"] = {
		["sound"] = 53401,
		["description"] = "Caverns of Time Escape Durnhold Intro",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["ct hillsbrad"] = {
		["sound"] = 53402,
		["description"] = "Caverns of Time Hillsbrad",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["ct hillsbrad2"] = {
		["sound"] = 53403,
		["description"] = "Caverns of Time Hillsbrad 2",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["ct hyjal7"] = {
		["sound"] = 53404,
		["description"] = "Caverns of Time Hyjal 7",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["ct hyjal8"] = {
		["sound"] = 53405,
		["description"] = "Caverns of Time Hyjal 8",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["ct hyjal9"] = {
		["sound"] = 53406,
		["description"] = "Caverns of Time Hyjal 9",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["ct hyjal"] = {
		["sound"] = 53407,
		["description"] = "Caverns of Time Hyjal",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["ct hyjal02"] = {
		["sound"] = 53408,
		["description"] = "Caverns of Time Hyjal 2",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["ct hyjal03"] = {
		["sound"] = 53409,
		["description"] = "Caverns of Time Hyjal 3",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["ct hyjal04"] = {
		["sound"] = 53410,
		["description"] = "Caverns of Time Hyjal 4",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["ct hyjal05"] = {
		["sound"] = 53411,
		["description"] = "Caverns of Time Hyjal 5",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["ct hyjal06"] = {
		["sound"] = 53412,
		["description"] = "Caverns of Time Hyjal 6",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["ct hyjal10"] = {
		["sound"] = 53413,
		["description"] = "Caverns of Time Hyjal 10",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["ct hyjal11"] = {
		["sound"] = 53414,
		["description"] = "Caverns of Time Hyjal 11",
		["type"] = soundType.MUSIC,
		["length"] = 49
	},
	["ct hyjal12"] = {
		["sound"] = 53415,
		["description"] = "Caverns of Time Hyjal 12",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["ct morassportalintro"] = {
		["sound"] = 53416,
		["description"] = "Caverns of Time Morass Portal Intro",
		["type"] = soundType.MUSIC,
		["length"] = 28
	},
	["ct morass"] = {
		["sound"] = 53417,
		["description"] = "Caverns of Time Morass",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["ct morass02"] = {
		["sound"] = 53418,
		["description"] = "Caverns of Time Morass 2",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["ct morass03"] = {
		["sound"] = 53419,
		["description"] = "Caverns of Time Morass 3",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["ct morass04"] = {
		["sound"] = 53420,
		["description"] = "Caverns of Time Morass 4",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["ct morass05"] = {
		["sound"] = 53421,
		["description"] = "Caverns of Time Morass 5",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["ct tarrenmill"] = {
		["sound"] = 53422,
		["description"] = "Caverns of Time Taren Mill",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["ct tarrenmill2"] = {
		["sound"] = 53423,
		["description"] = "Caverns of Time Taren Mill 2",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["ct tarrenmill3"] = {
		["sound"] = 53424,
		["description"] = "Caverns of Time Taren Mill 3",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["ct thrallescapeintro"] = {
		["sound"] = 53425,
		["description"] = "Caverns of Time Thrall Escape Intro",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["cursedland"] = {
		["sound"] = 53426,
		["description"] = "Cursed Land",
		["type"] = soundType.MUSIC,
		["length"] = 54
	},
	["cursedland02"] = {
		["sound"] = 53427,
		["description"] = "Cursed Land 2",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["cursedland03"] = {
		["sound"] = 53428,
		["description"] = "Cursed Land 3",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["cursedland04"] = {
		["sound"] = 53429,
		["description"] = "Cursed Land 4",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["cursedland05"] = {
		["sound"] = 53430,
		["description"] = "Cursed Land 5",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["cursedland06"] = {
		["sound"] = 53431,
		["description"] = "Cursed Land 6",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["day desert"] = {
		["sound"] = 53432,
		["description"] = "Day Desert",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["day desert02"] = {
		["sound"] = 53433,
		["description"] = "Day Desert 2",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["day desert03"] = {
		["sound"] = 53434,
		["description"] = "Day Desert 3",
		["type"] = soundType.MUSIC,
		["length"] = 54
	},
	["night desert"] = {
		["sound"] = 53435,
		["description"] = "Night Desert",
		["type"] = soundType.MUSIC,
		["length"] = 77
	},
	["night desert02"] = {
		["sound"] = 53436,
		["description"] = "Night Desert 2",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["night desert03"] = {
		["sound"] = 53437,
		["description"] = "Night Desert 3",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["poth"] = {
		["sound"] = 53438,
		["description"] = "Power of the Horde Song",
		["type"] = soundType.MUSIC,
		["length"] = 281
	},
	["db day"] = {
		["sound"] = 53439,
		["description"] = "Dragonblight Day",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["db day02"] = {
		["sound"] = 53440,
		["description"] = "Dragonblight Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["db day03"] = {
		["sound"] = 53441,
		["description"] = "Dragonblight Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["db day04"] = {
		["sound"] = 53442,
		["description"] = "Dragonblight Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["db night"] = {
		["sound"] = 53443,
		["description"] = "Dragonblight Night",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["db night02"] = {
		["sound"] = 53444,
		["description"] = "Dragonblight Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["db night03"] = {
		["sound"] = 53445,
		["description"] = "Dragonblight Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 119
	},
	["db night04"] = {
		["sound"] = 53446,
		["description"] = "Dragonblight Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["db induleday"] = {
		["sound"] = 53447,
		["description"] = "Dragonblight Lake Indule Day",
		["type"] = soundType.MUSIC,
		["length"] = 129
	},
	["db induleday02"] = {
		["sound"] = 53448,
		["description"] = "Dragonblight Lake Indule Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["db induleday03"] = {
		["sound"] = 53449,
		["description"] = "Dragonblight Lake Indule Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 38
	},
	["db indulenight"] = {
		["sound"] = 53450,
		["description"] = "Dragonblight Lake Indule Night",
		["type"] = soundType.MUSIC,
		["length"] = 132
	},
	["db indulenight02"] = {
		["sound"] = 53451,
		["description"] = "Dragonblight Lake Indule Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["db indulenight03"] = {
		["sound"] = 53452,
		["description"] = "Dragonblight Lake Indule Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 39
	},
	["enchanted forest"] = {
		["sound"] = 53453,
		["description"] = "Enchanted Forest",
		["type"] = soundType.MUSIC,
		["length"] = 49
	},
	["enchanted forest02"] = {
		["sound"] = 53454,
		["description"] = "Enchanted Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["enchanted forest03"] = {
		["sound"] = 53455,
		["description"] = "Enchanted Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 234
	},
	["enchanted forest04"] = {
		["sound"] = 53456,
		["description"] = "Enchanted Forest 4",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["enchanted forest05"] = {
		["sound"] = 53457,
		["description"] = "Enchanted Forest 5",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["es building day"] = {
		["sound"] = 53458,
		["description"] = "Eversong Woods Building Day",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["es building day02"] = {
		["sound"] = 53459,
		["description"] = "Eversong Woods Building Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["es building night"] = {
		["sound"] = 53460,
		["description"] = "Eversong Woods Building Night",
		["type"] = soundType.MUSIC,
		["length"] = 84
	},
	["es building night02"] = {
		["sound"] = 53461,
		["description"] = "Eversong Woods Building Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["es ruinsday"] = {
		["sound"] = 53462,
		["description"] = "Eversong Woods Ruins Day",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["es ruinsday02"] = {
		["sound"] = 53463,
		["description"] = "Eversong Woods Ruins Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["es ruinsday03"] = {
		["sound"] = 53464,
		["description"] = "Eversong Woods Ruins Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["es ruinsnight"] = {
		["sound"] = 53465,
		["description"] = "Eversong Woods Ruins Night",
		["type"] = soundType.MUSIC,
		["length"] = 50
	},
	["es ruinsnight02"] = {
		["sound"] = 53466,
		["description"] = "Eversong Woods Ruins Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["es ruinsnight03"] = {
		["sound"] = 53467,
		["description"] = "Eversong Woods Ruins Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["es scenicintronight"] = {
		["sound"] = 53468,
		["description"] = "Eversong Woods Scenic Intro Night",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["es scorchedday"] = {
		["sound"] = 53469,
		["description"] = "Eversong Woods Scorched Day",
		["type"] = soundType.MUSIC,
		["length"] = 116
	},
	["es scorchedday02"] = {
		["sound"] = 53470,
		["description"] = "Eversong Woods Scorched Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["es scorchednight"] = {
		["sound"] = 53471,
		["description"] = "Eversong Woods Scorched Night",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["es scorchednight02"] = {
		["sound"] = 53472,
		["description"] = "Eversong Woods Scorched Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["es silvermoonintro"] = {
		["sound"] = 53473,
		["description"] = "Eversong Woods Silvermoon Intro",
		["type"] = soundType.MUSIC,
		["length"] = 132
	},
	["es silvermoonday"] = {
		["sound"] = 53474,
		["description"] = "Eversong Woods Silvermoon Day",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["es silvermoonday02"] = {
		["sound"] = 53475,
		["description"] = "Eversong Woods Silvermoon Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["es silvermoonday03"] = {
		["sound"] = 53476,
		["description"] = "Eversong Woods Silvermoon Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["es silvermoonnight"] = {
		["sound"] = 53477,
		["description"] = "Eversong Woods Silvermoon Night",
		["type"] = soundType.MUSIC,
		["length"] = 177
	},
	["es silvermoonnight02"] = {
		["sound"] = 53478,
		["description"] = "Eversong Woods Silvermoon Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["es silvermoonnight03"] = {
		["sound"] = 53479,
		["description"] = "Eversong Woods Silvermoon Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["es sunstriderday"] = {
		["sound"] = 53480,
		["description"] = "Eversong Woods Sunstrider Day",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["es sunstriderday02"] = {
		["sound"] = 53481,
		["description"] = "Eversong Woods Sunstrider Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["es sunstriderday03"] = {
		["sound"] = 53482,
		["description"] = "Eversong Woods Sunstrider Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["es sunstridernight"] = {
		["sound"] = 53483,
		["description"] = "Eversong Woods Sunstrider Night",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["es sunstridernight02"] = {
		["sound"] = 53484,
		["description"] = "Eversong Woods Sunstrider Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["es sunstridernight03"] = {
		["sound"] = 53485,
		["description"] = "Eversong Woods Sunstrider Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["day evilforest"] = {
		["sound"] = 53486,
		["description"] = "Day Evil Forest",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["day evilforest02"] = {
		["sound"] = 53487,
		["description"] = "Day Evil Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["day evilforest03"] = {
		["sound"] = 53488,
		["description"] = "Day Evil Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["night evilforest"] = {
		["sound"] = 53489,
		["description"] = "Night Evil Forest",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["night evilforest02"] = {
		["sound"] = 53490,
		["description"] = "Night Evil Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["night evilforest03"] = {
		["sound"] = 53491,
		["description"] = "Night Evil Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["day elwynnforest"] = {
		["sound"] = 53492,
		["description"] = "Day Elwynn Forest",
		["type"] = soundType.MUSIC,
		["length"] = 55
	},
	["day elwynnforest02"] = {
		["sound"] = 53493,
		["description"] = "Day Elwynn Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["day elwynnforest03"] = {
		["sound"] = 53494,
		["description"] = "Day Elwynn Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["night elwynnforest"] = {
		["sound"] = 53495,
		["description"] = "Night Elwynn Forest",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["night elwynnforest02"] = {
		["sound"] = 53496,
		["description"] = "Night Elwynn Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 42
	},
	["night elwynnforest03"] = {
		["sound"] = 53497,
		["description"] = "Night Elwynn Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["night elwynnforest04"] = {
		["sound"] = 53498,
		["description"] = "Night Elwynn Forest 4",
		["type"] = soundType.MUSIC,
		["length"] = 54
	},
	["gl eversongdark"] = {
		["sound"] = 53499,
		["description"] = "Ghostlands Eversong Dark",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["gl eversongdark02"] = {
		["sound"] = 53500,
		["description"] = "Ghostlands Eversong Dark 2",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["gl eversongdark03"] = {
		["sound"] = 53501,
		["description"] = "Ghostlands Eversong Dark 3",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["gl eversongdark04"] = {
		["sound"] = 53502,
		["description"] = "Ghostlands Eversong Dark 4",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["gl forestday"] = {
		["sound"] = 53503,
		["description"] = "Ghostlands Forest Day",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["gl forestday02"] = {
		["sound"] = 53504,
		["description"] = "Ghostlands Forest Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["gl forestnight"] = {
		["sound"] = 53505,
		["description"] = "Ghostlands Forest Night",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["gl forest2day"] = {
		["sound"] = 53506,
		["description"] = "Ghostlands Forest 2 Day",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["gl forest2night"] = {
		["sound"] = 53507,
		["description"] = "Ghostlands Forest 2 Night",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["gl forest2night02"] = {
		["sound"] = 53508,
		["description"] = "Ghostlands Forest 2 Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["gl forest3day"] = {
		["sound"] = 53509,
		["description"] = "Ghostlands Forest 3 Day",
		["type"] = soundType.MUSIC,
		["length"] = 154
	},
	["gl forest3night"] = {
		["sound"] = 53510,
		["description"] = "Ghostlands Forest 3 Night",
		["type"] = soundType.MUSIC,
		["length"] = 51
	},
	["gl forest3night02"] = {
		["sound"] = 53511,
		["description"] = "Ghostlands Forest 3 Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 28
	},
	["gl forest3night03"] = {
		["sound"] = 53512,
		["description"] = "Ghostlands Forest 3 Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 44
	},
	["gl scenic"] = {
		["sound"] = 53513,
		["description"] = "Ghostlands Scenic",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["gl scenic02"] = {
		["sound"] = 53514,
		["description"] = "Ghostlands Scenic 2",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["gl scenic03"] = {
		["sound"] = 53515,
		["description"] = "Ghostlands Scenic 3",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["gl shalandis"] = {
		["sound"] = 53516,
		["description"] = "Ghostlands Shalandis Isle",
		["type"] = soundType.MUSIC,
		["length"] = 131
	},
	["gl shalandis02"] = {
		["sound"] = 53517,
		["description"] = "Ghostlands Shalandis Isle 2",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["gl shalandis03"] = {
		["sound"] = 53518,
		["description"] = "Ghostlands Shalandis Isle 3",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["ghostmusic03"] = {
		["sound"] = 53519,
		["description"] = "Ghostlands Ghostmusic 3",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["he ogre"] = {
		["sound"] = 53520,
		["description"] = "Hellfire Peninsula Ogre",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["he ogre02"] = {
		["sound"] = 53521,
		["description"] = "Hellfire Peninsula Ogre 2",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["he armoryintro"] = {
		["sound"] = 53522,
		["description"] = "Hellfire Peninsula Armory Intro",
		["type"] = soundType.MUSIC,
		["length"] = 14
	},
	["he citadeldemon"] = {
		["sound"] = 53523,
		["description"] = "Hellfire Peninsula Citadel Demon",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["he citadeldemon02"] = {
		["sound"] = 535243,
		["description"] = "Hellfire Peninsula Citadel Demon 2",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["he citadelintro"] = {
		["sound"] = 53525,
		["description"] = "Hellfire Peninsula Citadel Intro",
		["type"] = soundType.MUSIC,
		["length"] = 19
	},
	["he general"] = {
		["sound"] = 53526,
		["description"] = "Hellfire Peninsula General",
		["type"] = soundType.MUSIC,
		["length"] = 130
	},
	["he general02"] = {
		["sound"] = 53527,
		["description"] = "Hellfire Peninsula General 2",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["he general03"] = {
		["sound"] = 53528,
		["description"] = "Hellfire Peninsula General 3",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["he general04"] = {
		["sound"] = 53529,
		["description"] = "Hellfire Peninsula General 4",
		["type"] = soundType.MUSIC,
		["length"] = 96
	},
	["he general05"] = {
		["sound"] = 53530,
		["description"] = "Hellfire Peninsula General 5",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["he pogintro"] = {
		["sound"] = 53531,
		["description"] = "Hellfire Peninsula Path of Glory Intro",
		["type"] = soundType.MUSIC,
		["length"] = 18
	},
	["he ramparts"] = {
		["sound"] = 53532,
		["description"] = "Hellfire Peninsula Ramparts",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["he ramparts02"] = {
		["sound"] = 53533,
		["description"] = "Hellfire Peninsula Ramparts 2",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["he stairsintro"] = {
		["sound"] = 53534,
		["description"] = "Hellfire Peninsula Stairs Intro",
		["type"] = soundType.MUSIC,
		["length"] = 18
	},
	["he wistfulintro"] = {
		["sound"] = 53535,
		["description"] = "Hellfire Peninsula Wistful Intro",
		["type"] = soundType.MUSIC,
		["length"] = 25
	},
	["he wistfulintro02"] = {
		["sound"] = 53536,
		["description"] = "Hellfire Peninsula Wistful Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 17
	},
	["hf kamaguaday"] = {
		["sound"] = 53537,
		["description"] = "Howling Fjord Kamagua Day",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["hf kamaguaday02"] = {
		["sound"] = 53538,
		["description"] = "Howling Fjord Kamagua Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 54
	},
	["hf kamaguanight"] = {
		["sound"] = 53539,
		["description"] = "Howling Fjord Kamagua Night",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["hf kamaguanight02"] = {
		["sound"] = 53540,
		["description"] = "Howling Fjord Kamagua Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["day jungle"] = {
		["sound"] = 53541,
		["description"] = "Day Jungle",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["day jungle02"] = {
		["sound"] = 53542,
		["description"] = "Day Jungle 2",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["day jungle03"] = {
		["sound"] = 53543,
		["description"] = "Day Jungle 3",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["night jungle"] = {
		["sound"] = 53544,
		["description"] = "Night Jungle",
		["type"] = soundType.MUSIC,
		["length"] = 54
	},
	["night jungle02"] = {
		["sound"] = 53545,
		["description"] = "Night Jungle 2",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["night jungle03"] = {
		["sound"] = 53546,
		["description"] = "Night Jungle 3",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["ka backstage"] = {
		["sound"] = 53547,
		["description"] = "Karazhan Backstage",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["ka backstage02"] = {
		["sound"] = 53548,
		["description"] = "Karazhan Backstage 2",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["ka foyerintro"] = {
		["sound"] = 53549,
		["description"] = "Karazhan Foyer Intro",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["ka foyer"] = {
		["sound"] = 53550,
		["description"] = "Karazhan Foyer",
		["type"] = soundType.MUSIC,
		["length"] = 113
	},
	["ka foyer02"] = {
		["sound"] = 53551,
		["description"] = "Karazhan Foyer 2",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["ka foyer03"] = {
		["sound"] = 53552,
		["description"] = "Karazhan Foyer 3",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["ka foyer04"] = {
		["sound"] = 53553,
		["description"] = "Karazhan Foyer 4",
		["type"] = soundType.MUSIC,
		["length"] = 31
	},
	["ka general"] = {
		["sound"] = 53554,
		["description"] = "Karazhan General",
		["type"] = soundType.MUSIC,
		["length"] = 130
	},
	["ka general02"] = {
		["sound"] = 53555,
		["description"] = "Karazhan General 2",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["ka general03"] = {
		["sound"] = 53556,
		["description"] = "Karazhan General 3",
		["type"] = soundType.MUSIC,
		["length"] = 118
	},
	["ka general04"] = {
		["sound"] = 53557,
		["description"] = "Karazhan General 4",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["ka general05"] = {
		["sound"] = 53558,
		["description"] = "Karazhan General 5",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["ka general06"] = {
		["sound"] = 53559,
		["description"] = "Karazhan General 6",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["ka general07"] = {
		["sound"] = 53560,
		["description"] = "Karazhan General 7",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["ka library"] = {
		["sound"] = 53561,
		["description"] = "Karazhan Library",
		["type"] = soundType.MUSIC,
		["length"] = 127
	},
	["ka library02"] = {
		["sound"] = 53562,
		["description"] = "Karazhan Library 2",
		["type"] = soundType.MUSIC,
		["length"] = 147
	},
	["ka library03"] = {
		["sound"] = 53563,
		["description"] = "Karazhan Library 3",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["ka library04"] = {
		["sound"] = 53564,
		["description"] = "Karazhan Library 4",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["ka malchezar"] = {
		["sound"] = 53565,
		["description"] = "Karazhan Malchezar",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["ka malchezar02"] = {
		["sound"] = 53566,
		["description"] = "Karazhan Malchezar 2",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["ka malchezar03"] = {
		["sound"] = 53567,
		["description"] = "Karazhan Malchezar 3",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["ka operaharpsi"] = {
		["sound"] = 53568,
		["description"] = "Karazhan Hapsichord Opera",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["ka operaorgan"] = {
		["sound"] = 53569,
		["description"] = "Karazhan Organ Opera",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["ka stableintro"] = {
		["sound"] = 53570,
		["description"] = "Karazhan Stable Intro",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["ka stable"] = {
		["sound"] = 53571,
		["description"] = "Karazhan Stable",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["ka stable02"] = {
		["sound"] = 53572,
		["description"] = "Karazhan Stable 2",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["ka stable03"] = {
		["sound"] = 53573,
		["description"] = "Karazhan Stable 3",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["ka tower"] = {
		["sound"] = 53574,
		["description"] = "Karazhan Tower",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["ka tower02"] = {
		["sound"] = 53575,
		["description"] = "Karazhan Tower 2",
		["type"] = soundType.MUSIC,
		["length"] = 115
	},
	["ka tower03"] = {
		["sound"] = 53576,
		["description"] = "Karazhan Tower 3",
		["type"] = soundType.MUSIC,
		["length"] = 127
	},
	["day mountain"] = {
		["sound"] = 53577,
		["description"] = "Day Mountain",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["day mountain02"] = {
		["sound"] = 53578,
		["description"] = "Day Mountain 2",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["day mountain03"] = {
		["sound"] = 53579,
		["description"] = "Day Mountain 3",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["night mountain"] = {
		["sound"] = 53580,
		["description"] = "Night Mountain",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["night mountain02"] = {
		["sound"] = 53581,
		["description"] = "Night Mountain 2",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["night mountain03"] = {
		["sound"] = 53582,
		["description"] = "Night Mountain 3",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["night mountain04"] = {
		["sound"] = 53583,
		["description"] = "Night Mountain 4",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["na diamondintro"] = {
		["sound"] = 53584,
		["description"] = "Nagrand Diamond Intro",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["na day"] = {
		["sound"] = 53585,
		["description"] = "Nagrand Day",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["na day02"] = {
		["sound"] = 53586,
		["description"] = "Nagrand Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["na day03"] = {
		["sound"] = 53587,
		["description"] = "Nagrand Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["na night"] = {
		["sound"] = 53588,
		["description"] = "Nagrand Night",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["na night02"] = {
		["sound"] = 53589,
		["description"] = "Nagrand Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["na night03"] = {
		["sound"] = 53590,
		["description"] = "Nagrand Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 166
	},
	["naxx abominationboss"] = {
		["sound"] = 53591,
		["description"] = "Naxxramas Abomination Boss",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["naxx abominationboss2"] = {
		["sound"] = 53592,
		["description"] = "Naxxramas Abomination Boss 2",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["naxx abominationwing"] = {
		["sound"] = 53593,
		["description"] = "Naxxramas Abomination Wing",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["naxx abominationwing2"] = {
		["sound"] = 53594,
		["description"] = "Naxxramas Abomination Wing 2",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["naxx abominationwing3"] = {
		["sound"] = 53595,
		["description"] = "Naxxramas Abomination Wing 3",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["naxx frostwyrm"] = {
		["sound"] = 53596,
		["description"] = "Naxxramas Frostwyrm",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["naxx frostwyrm2"] = {
		["sound"] = 53597,
		["description"] = "Naxxramas Frostwyrm 2",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["naxx frostwyrm3"] = {
		["sound"] = 53598,
		["description"] = "Naxxramas Frostwyrm 3",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["naxx frostwyrm4"] = {
		["sound"] = 53599,
		["description"] = "Naxxramas Frostwyrm 4",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["naxx hubbase"] = {
		["sound"] = 53600,
		["description"] = "Naxxramas Hub Base",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["naxx hubbase2"] = {
		["sound"] = 53601,
		["description"] = "Naxxramas Hub Base 2",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["naxx kelthuzad"] = {
		["sound"] = 53602,
		["description"] = "Naxxramas Kel'Thuzad",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["naxx kelthuzad2"] = {
		["sound"] = 53603,
		["description"] = "Naxxramas Kel'Thuzad 2",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["naxx kelthuzad3"] = {
		["sound"] = 53604,
		["description"] = "Naxxramas Kel'Thuzad 3",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["naxx plagueboss"] = {
		["sound"] = 53605,
		["description"] = "Naxxramas Plague Boss",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["naxx plaguewing"] = {
		["sound"] = 53606,
		["description"] = "Naxxramas Plague Wing",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["naxx plaguewing2"] = {
		["sound"] = 53607,
		["description"] = "Naxxramas Plague Wing 2",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["naxx plaguewing3"] = {
		["sound"] = 53608,
		["description"] = "Naxxramas Plague Wing 3",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["naxx spiderboss"] = {
		["sound"] = 53609,
		["description"] = "Naxxramas Spider Boss",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["naxx spiderboss2"] = {
		["sound"] = 53610,
		["description"] = "Naxxramas Spider Boss 2",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["naxx spiderwing"] = {
		["sound"] = 53611,
		["description"] = "Naxxramas Spider Wing",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["naxx spiderwing2"] = {
		["sound"] = 53612,
		["description"] = "Naxxramas Spider Wing 2",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["naxx spiderwing3"] = {
		["sound"] = 53613,
		["description"] = "Naxxramas Spider Wing 3",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["naxx"] = {
		["sound"] = 53614,
		["description"] = "Naxxramas",
		["type"] = soundType.MUSIC,
		["length"] = 101
	},
	["naxx2"] = {
		["sound"] = 53615,
		["description"] = "Naxxramas 2",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["naxx3"] = {
		["sound"] = 53616,
		["description"] = "Naxxramas 3",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["naxx4"] = {
		["sound"] = 53617,
		["description"] = "Naxxramas 4",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["naxx5"] = {
		["sound"] = 53618,
		["description"] = "Naxxramas 5",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["naxx6"] = {
		["sound"] = 53619,
		["description"] = "Naxxramas 6",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["nes general"] = {
		["sound"] = 53620,
		["description"] = "Netherstorm General",
		["type"] = soundType.MUSIC,
		["length"] = 150
	},
	["nes general02"] = {
		["sound"] = 53621,
		["description"] = "Netherstorm General 2",
		["type"] = soundType.MUSIC,
		["length"] = 175
	},
	["nes general03"] = {
		["sound"] = 53622,
		["description"] = "Netherstorm General 3",
		["type"] = soundType.MUSIC,
		["length"] = 178
	},
	["nes general04"] = {
		["sound"] = 53623,
		["description"] = "Netherstorm General 4",
		["type"] = soundType.MUSIC,
		["length"] = 181
	},
	["nes general05"] = {
		["sound"] = 53624,
		["description"] = "Netherstorm General 5",
		["type"] = soundType.MUSIC,
		["length"] = 184
	},
	["nes general06"] = {
		["sound"] = 53625,
		["description"] = "Netherstorm General 6",
		["type"] = soundType.MUSIC,
		["length"] = 192
	},
	["nes general07"] = {
		["sound"] = 53626,
		["description"] = "Netherstorm General 7",
		["type"] = soundType.MUSIC,
		["length"] = 193
	},
	["nes general08"] = {
		["sound"] = 53627,
		["description"] = "Netherstorm General 8",
		["type"] = soundType.MUSIC,
		["length"] = 168
	},
	["nes general09"] = {
		["sound"] = 53628,
		["description"] = "Netherstorm General 9",
		["type"] = soundType.MUSIC,
		["length"] = 199
	},
	["nes general10"] = {
		["sound"] = 53629,
		["description"] = "Netherstorm General 10",
		["type"] = soundType.MUSIC,
		["length"] = 222
	},
	["nes mushroomintro"] = {
		["sound"] = 53630,
		["description"] = "Netherstorm Mushroom Intro",
		["type"] = soundType.MUSIC,
		["length"] = 39
	},
	["nes mushroomintro02"] = {
		["sound"] = 53631,
		["description"] = "Netherstorm Mushroom Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 33
	},
	["nes mushroomintro03"] = {
		["sound"] = 53632,
		["description"] = "Netherstorm Mushroom Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 36
	},
	["nes netherplantintro"] = {
		["sound"] = 53633,
		["description"] = "Netherstorm Netherplant Intro",
		["type"] = soundType.MUSIC,
		["length"] = 44
	},
	["nes netherplantintro02"] = {
		["sound"] = 53634,
		["description"] = "Netherstorm Netherplant Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 51
	},
	["nes netherplantintro03"] = {
		["sound"] = 53635,
		["description"] = "Netherstorm Netherplant Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["nes netherplantintro04"] = {
		["sound"] = 53636,
		["description"] = "Netherstorm Netherplant Intro 4",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["ol action"] = {
		["sound"] = 53637,
		["description"] = "Outland Action",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["ol alliancebase"] = {
		["sound"] = 53638,
		["description"] = "Outland Alliance Base",
		["type"] = soundType.MUSIC,
		["length"] = 134
	},
	["ol alliancebase02"] = {
		["sound"] = 53639,
		["description"] = "Outland Alliance Base 2",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["ol arakkoaintro"] = {
		["sound"] = 53640,
		["description"] = "Outland Arakkoa Intro",
		["type"] = soundType.MUSIC,
		["length"] = 18
	},
	["ol arakkoaintro02"] = {
		["sound"] = 53641,
		["description"] = "Outland Arakkoa Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 14
	},
	["ol bloodelfbase"] = {
		["sound"] = 53642,
		["description"] = "Outland Blood Elf Base",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["ol bloodelfbase02"] = {
		["sound"] = 53643,
		["description"] = "Outland Blood Elf Base 2",
		["type"] = soundType.MUSIC,
		["length"] = 121
	},
	["ol blintro"] = {
		["sound"] = 53644,
		["description"] = "Outland Burning Legion Intro",
		["type"] = soundType.MUSIC,
		["length"] = 16
	},
	["ol blintro02"] = {
		["sound"] = 53645,
		["description"] = "Outland Burning Legion Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 35
	},
	["ol cenarionintro"] = {
		["sound"] = 53646,
		["description"] = "Outland Cenarion Intro",
		["type"] = soundType.MUSIC,
		["length"] = 44
	},
	["ol cenarionintro02"] = {
		["sound"] = 53647,
		["description"] = "Outland Cenarion Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["ol cenarionintro03"] = {
		["sound"] = 53648,
		["description"] = "Outland Cenarion Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["ol corrupt"] = {
		["sound"] = 53649,
		["description"] = "Outland Corrupt",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["ol corrupt02"] = {
		["sound"] = 53650,
		["description"] = "Outland Corrupt 2",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["ol corrupt03"] = {
		["sound"] = 53651,
		["description"] = "Outland Corrupt 3",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["ol corrupt04"] = {
		["sound"] = 53652,
		["description"] = "Outland Corrupt 4",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["ol corrupt05"] = {
		["sound"] = 53653,
		["description"] = "Outland Corrupt 5",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["ol corrupt06"] = {
		["sound"] = 53654,
		["description"] = "Outland Corrupt 6",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["ol corrupt07"] = {
		["sound"] = 53655,
		["description"] = "Outland Corrupt 7",
		["type"] = soundType.MUSIC,
		["length"] = 52
	},
	["ol corruptintro"] = {
		["sound"] = 53656,
		["description"] = "Outland Corrupt Intro",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["ol crystalintro"] = {
		["sound"] = 53657,
		["description"] = "Outland Crystal Intro",
		["type"] = soundType.MUSIC,
		["length"] = 26
	},
	["ol crystalintro02"] = {
		["sound"] = 53658,
		["description"] = "Outland Crystal Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 21
	},
	["ol crystalintro03"] = {
		["sound"] = 53659,
		["description"] = "Outland Crystal Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 21
	},
	["ol demonintro"] = {
		["sound"] = 53660,
		["description"] = "Outland Demon Intro",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["ol draeneibase"] = {
		["sound"] = 53661,
		["description"] = "Outland Draenei Base",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["ol draeneibase02"] = {
		["sound"] = 53662,
		["description"] = "Outland Draenei Base 2",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["ol felorcintro"] = {
		["sound"] = 53663,
		["description"] = "Outland Felorc Intro",
		["type"] = soundType.MUSIC,
		["length"] = 16
	},
	["ol felorcintro02"] = {
		["sound"] = 53664,
		["description"] = "Outland Felorc Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 14
	},
	["ol historicintro"] = {
		["sound"] = 53665,
		["description"] = "Outland Historic Intro",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["ol hordebase"] = {
		["sound"] = 53666,
		["description"] = "Outland Horde Base",
		["type"] = soundType.MUSIC,
		["length"] = 40
	},
	["ol hordebase02"] = {
		["sound"] = 53667,
		["description"] = "Outland Horde Base 2",
		["type"] = soundType.MUSIC,
		["length"] = 37
	},
	["ol hordebase03"] = {
		["sound"] = 53668,
		["description"] = "Outland Horde Base 3",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["ol hordebase04"] = {
		["sound"] = 53669,
		["description"] = "Outland Horde Base 4",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["ol illidansarmyintro"] = {
		["sound"] = 53670,
		["description"] = "Outland Illidans Army Intro",
		["type"] = soundType.MUSIC,
		["length"] = 35
	},
	["ol ogreintro"] = {
		["sound"] = 53671,
		["description"] = "Outland Ogre Intro",
		["type"] = soundType.MUSIC,
		["length"] = 28
	},
	["ol ogreintro02"] = {
		["sound"] = 53672,
		["description"] = "Outland Ogre Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 25
	},
	["ol orcintro"] = {
		["sound"] = 53673,
		["description"] = "Outland Orc Intro",
		["type"] = soundType.MUSIC,
		["length"] = 11
	},
	["ol orcintro02"] = {
		["sound"] = 53674,
		["description"] = "Outland Orc Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 17
	},
	["ol orcintro03"] = {
		["sound"] = 53675,
		["description"] = "Outland Orc Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 11
	},
	["ol orcintro04"] = {
		["sound"] = 53676,
		["description"] = "Outland Orc Intro 4",
		["type"] = soundType.MUSIC,
		["length"] = 13
	},
	["ol scenicintro"] = {
		["sound"] = 53677,
		["description"] = "Outland Scenic Intro",
		["type"] = soundType.MUSIC,
		["length"] = 31
	},
	["ol shamanintro"] = {
		["sound"] = 53678,
		["description"] = "Outland Shaman Intro",
		["type"] = soundType.MUSIC,
		["length"] = 44
	},
	["ol shamanintro02"] = {
		["sound"] = 53679,
		["description"] = "Outland Shaman Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["day plains"] = {
		["sound"] = 53680,
		["description"] = "Day Plains",
		["type"] = soundType.MUSIC,
		["length"] = 53
	},
	["day plains02"] = {
		["sound"] = 53681,
		["description"] = "Day Plains 2",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["night plains"] = {
		["sound"] = 53682,
		["description"] = "Night Plains",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["night plains02"] = {
		["sound"] = 53683,
		["description"] = "Night Plains 2",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["pvp"] = {
		["sound"] = 53684,
		["description"] = "PVP",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["pvp2"] = {
		["sound"] = 53685,
		["description"] = "PVP 2",
		["type"] = soundType.MUSIC,
		["length"] = 52
	},
	["pvp3"] = {
		["sound"] = 53686,
		["description"] = "PVP 3",
		["type"] = soundType.MUSIC,
		["length"] = 40
	},
	["pvp4"] = {
		["sound"] = 53687,
		["description"] = "PVP 4",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["pvp5"] = {
		["sound"] = 53688,
		["description"] = "PVP 5",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["sv general"] = {
		["sound"] = 53689,
		["description"] = "Shadowmoon Valley General",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["sv general02"] = {
		["sound"] = 53690,
		["description"] = "Shadowmoon Valley General 2",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["sv general03"] = {
		["sound"] = 53691,
		["description"] = "Shadowmoon Valley General 3",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["sv general04"] = {
		["sound"] = 53692,
		["description"] = "Shadowmoon Valley General 4",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["sv general05"] = {
		["sound"] = 53693,
		["description"] = "Shadowmoon Valley General 5",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["sv general06"] = {
		["sound"] = 53694,
		["description"] = "Shadowmoon Valley General 6",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["soggyplace zone"] = {
		["sound"] = 53695,
		["description"] = "Soggy Place Zone",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["soggyplace zone2"] = {
		["sound"] = 53696,
		["description"] = "Soggy Place Zone 2",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["soggyplace zone3"] = {
		["sound"] = 53697,
		["description"] = "Soggy Place Zone 3",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["soggyplace zone4"] = {
		["sound"] = 53698,
		["description"] = "Soggy Place Zone 4",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["soggyplace zone5"] = {
		["sound"] = 53699,
		["description"] = "Soggy Place Zone 5",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["sunw assemblychamber"] = {
		["sound"] = 53700,
		["description"] = "Sunwell Assembly Chamber",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["sunw assemblychamber02"] = {
		["sound"] = 53701,
		["description"] = "Sunwell Assembly Chamber 2",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["sunw felenergy"] = {
		["sound"] = 53702,
		["description"] = "Sunwell Fel Energy",
		["type"] = soundType.MUSIC,
		["length"] = 125
	},
	["sunw isledark"] = {
		["sound"] = 53703,
		["description"] = "Sunwell Isle Dark",
		["type"] = soundType.MUSIC,
		["length"] = 139
	},
	["sunw isledark02"] = {
		["sound"] = 53704,
		["description"] = "Sunwell Isle Dark 2",
		["type"] = soundType.MUSIC,
		["length"] = 137
	},
	["sunw isledark03"] = {
		["sound"] = 53705,
		["description"] = "Sunwell Isle Dark 3",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["sunw islelight"] = {
		["sound"] = 53706,
		["description"] = "Sunwell Isle Light",
		["type"] = soundType.MUSIC,
		["length"] = 115
	},
	["sunw islelight02"] = {
		["sound"] = 53707,
		["description"] = "Sunwell Isle Light 2",
		["type"] = soundType.MUSIC,
		["length"] = 119
	},
	["sunw islelight03"] = {
		["sound"] = 53708,
		["description"] = "Sunwell Isle Light 3",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["sunw islemed"] = {
		["sound"] = 53709,
		["description"] = "Sunwell Isle Med",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["sunw islemed02"] = {
		["sound"] = 53710,
		["description"] = "Sunwell Isle Med 2",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["sunw islemed03"] = {
		["sound"] = 53711,
		["description"] = "Sunwell Isle Med 3",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["sunw magistersarrival"] = {
		["sound"] = 53712,
		["description"] = "Sunwell Magisters Arrival",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["sunw magistersasylum"] = {
		["sound"] = 53713,
		["description"] = "Sunwell Magisters Asylum",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["sunw magistersasylum02"] = {
		["sound"] = 53714,
		["description"] = "Sunwell Magisters Asylum 2",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["sunw magistersasylum03"] = {
		["sound"] = 53715,
		["description"] = "Sunwell Magisters Asylum 3",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["sunw magistersterrace"] = {
		["sound"] = 53716,
		["description"] = "Sunwell Magisters Terrace",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["sunw magistersterrace02"] = {
		["sound"] = 53717,
		["description"] = "Sunwell Magisters Terrace 2",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["sunw magistersterrace03"] = {
		["sound"] = 53718,
		["description"] = "Sunwell Magisters Terrace 3",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["sunw magistersterrace04"] = {
		["sound"] = 53719,
		["description"] = "Sunwell Magisters Terrace 4",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["sunw magistersterrace05"] = {
		["sound"] = 53720,
		["description"] = "Sunwell Magisters Terrace 5",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["sunw plateauarrival"] = {
		["sound"] = 53721,
		["description"] = "Sunwell Plateau Arrival",
		["type"] = soundType.MUSIC,
		["length"] = 138
	},
	["sunw plateau"] = {
		["sound"] = 53722,
		["description"] = "Sunwell Plateau",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["sunw plateau02"] = {
		["sound"] = 53723,
		["description"] = "Sunwell Plateau 2",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["sunw plateau03"] = {
		["sound"] = 53724,
		["description"] = "Sunwell Plateau 3",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["sunw plateau04"] = {
		["sound"] = 53725,
		["description"] = "Sunwell Plateau 4",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["sunw plateau05"] = {
		["sound"] = 53726,
		["description"] = "Sunwell Plateau 5",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["sunw plateau06"] = {
		["sound"] = 53727,
		["description"] = "Sunwell Plateau 6",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["sunw queldanas"] = {
		["sound"] = 53728,
		["description"] = "Sunwell Quel'Danas",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["sunw queldanas02"] = {
		["sound"] = 53729,
		["description"] = "Sunwell Quel'Danas 2",
		["type"] = soundType.MUSIC,
		["length"] = 84
	},
	["sunw sanctum"] = {
		["sound"] = 53730,
		["description"] = "Sunwell Sanctum",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["sunw shorelaran"] = {
		["sound"] = 53731,
		["description"] = "Sunwell Shorel'aran",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["sunw bombingrun"] = {
		["sound"] = 53732,
		["description"] = "Sunwell Bombing Run",
		["type"] = soundType.MUSIC,
		["length"] = 259
	},
	["sunw flyby"] = {
		["sound"] = 53733,
		["description"] = "Sunwell fly by",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["sunw thewell"] = {
		["sound"] = 53734,
		["description"] = "Sunwell the Well",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["sunw thewell02"] = {
		["sound"] = 53735,
		["description"] = "Sunwell the Well 2",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["sunw thewell03"] = {
		["sound"] = 53736,
		["description"] = "Sunwell the Well 3",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["tavern alliance"] = {
		["sound"] = 53737,
		["description"] = "Tavern Alliance",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["tavern alliance02"] = {
		["sound"] = 53738,
		["description"] = "Tavern Alliance 2",
		["type"] = soundType.MUSIC,
		["length"] = 51
	},
	["tavern dwarf1a"] = {
		["sound"] = 53739,
		["description"] = "Tavern Dwarf 1a",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["tavern dwarf1b"] = {
		["sound"] = 53740,
		["description"] = "Tavern Dwarf 1b",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["tavern dwarf2a"] = {
		["sound"] = 53741,
		["description"] = "Tavern Dwarf 2a",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["tavern dwarf2b"] = {
		["sound"] = 53742,
		["description"] = "Tavern Dwarf 2b",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["tavern dwarf3"] = {
		["sound"] = 53743,
		["description"] = "Tavern Dwarf 3",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["tavern horde"] = {
		["sound"] = 53744,
		["description"] = "Tavern Horde",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["tavern horde02"] = {
		["sound"] = 53745,
		["description"] = "Tavern Horde 2",
		["type"] = soundType.MUSIC,
		["length"] = 39
	},
	["tavern horde03"] = {
		["sound"] = 53746,
		["description"] = "Tavern Horde 3",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["dance undead"] = {
		["sound"] = 53747,
		["description"] = "Dance Undead",
		["type"] = soundType.MUSIC,
		["length"] = 25
	},
	["tavern human1a"] = {
		["sound"] = 53748,
		["description"] = "Tavern Human 1a",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["tavern human1b"] = {
		["sound"] = 53749,
		["description"] = "Tavern Human 1b",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["tavern human2a"] = {
		["sound"] = 53750,
		["description"] = "Tavern Human 2a",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["tavern human2b"] = {
		["sound"] = 53751,
		["description"] = "Tavern Human 2b",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["tavern humanrevisited"] = {
		["sound"] = 53752,
		["description"] = "Tavern Human revisited",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["tavern humanrevisited2"] = {
		["sound"] = 53753,
		["description"] = "Tavern Human revisited 2",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["tavern templeofthemoon"] = {
		["sound"] = 53754,
		["description"] = "Tavern Nightelf Temple of the Moon",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["tavern templeofthemoon2"] = {
		["sound"] = 53755,
		["description"] = "Tavern Nightelf Temple of the Moon 2",
		["type"] = soundType.MUSIC,
		["length"] = 119
	},
	["tavern orcrest1a"] = {
		["sound"] = 53756,
		["description"] = "Tavern Orc Rest 1a",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["tavern orcrest1b"] = {
		["sound"] = 53757,
		["description"] = "Tavern Orc Rest 1b",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["tavern orcrest2a"] = {
		["sound"] = 53758,
		["description"] = "Tavern Orc Rest 2a",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["tavern orcrest2b"] = {
		["sound"] = 53759,
		["description"] = "Tavern Orc Rest 2b",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["tavern orcrest3a"] = {
		["sound"] = 53760,
		["description"] = "Tavern Orc Rest 3a",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["tavern orcrest3b"] = {
		["sound"] = 53761,
		["description"] = "Tavern Orc Rest 3b",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["tavern pirate1a"] = {
		["sound"] = 53762,
		["description"] = "Tavern Pirate 1a",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["tavern pirate1b"] = {
		["sound"] = 53763,
		["description"] = "Tavern Pirate 1b",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["tavern pirate2a"] = {
		["sound"] = 53764,
		["description"] = "Tavern Pirate 2a",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["tavern pirate2b"] = {
		["sound"] = 53765,
		["description"] = "Tavern Pirate 2b",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["tavern pirate3"] = {
		["sound"] = 53767,
		["description"] = "Tavern Pirate 3",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["tavern taurenrest1a"] = {
		["sound"] = 53768,
		["description"] = "Tavern Tauren Rest 1a",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["tavern taurenrest1b"] = {
		["sound"] = 53769,
		["description"] = "Tavern Tauren Rest 1b",
		["type"] = soundType.MUSIC,
		["length"] = 96
	},
	["tavern taurenrest2a"] = {
		["sound"] = 53770,
		["description"] = "Tavern Tauren Rest 2a",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["tavern taurenrest2b"] = {
		["sound"] = 53771,
		["description"] = "Tavern Tauren Rest 2b",
		["type"] = soundType.MUSIC,
		["length"] = 80
	},
	["tavern taurenrest3a"] = {
		["sound"] = 53772,
		["description"] = "Tavern Tauren Rest 3a",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["tavern taurenrest3b"] = {
		["sound"] = 53773,
		["description"] = "Tavern Tauren Rest 3b",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["tavern undead1a"] = {
		["sound"] = 53774,
		["description"] = "Tavern Undead 1a",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["tavern undead1b"] = {
		["sound"] = 53775,
		["description"] = "Tavern Undead 1b",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["tavern undead2"] = {
		["sound"] = 53776,
		["description"] = "Tavern Undead 2",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["tavern undead3a"] = {
		["sound"] = 53777,
		["description"] = "Tavern Undead 3a",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["tavern undead3b"] = {
		["sound"] = 53778,
		["description"] = "Tavern Undead 3b",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["tk amb11"] = {
		["sound"] = 53779,
		["description"] = "Tempest Keep amb 11",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["tk amb12"] = {
		["sound"] = 53780,
		["description"] = "Tempest Keep amb 12",
		["type"] = soundType.MUSIC,
		["length"] = 96
	},
	["tk amb13"] = {
		["sound"] = 53781,
		["description"] = "Tempest Keep amb 13",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["tk amb14"] = {
		["sound"] = 53782,
		["description"] = "Tempest Keep amb 14",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["tk amb16"] = {
		["sound"] = 53783,
		["description"] = "Tempest Keep amb 16",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["tk amb17"] = {
		["sound"] = 53784,
		["description"] = "Tempest Keep amb 17",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["tk amb18"] = {
		["sound"] = 53785,
		["description"] = "Tempest Keep amb 18",
		["type"] = soundType.MUSIC,
		["length"] = 85
	},
	["tk amb19"] = {
		["sound"] = 53786,
		["description"] = "Tempest Keep amb 19",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["tk amb20"] = {
		["sound"] = 53787,
		["description"] = "Tempest Keep amb 20",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["tk amb22"] = {
		["sound"] = 53788,
		["description"] = "Tempest Keep amb 22",
		["type"] = soundType.MUSIC,
		["length"] = 34
	},
	["tk amb23"] = {
		["sound"] = 53789,
		["description"] = "Tempest Keep amb 23",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["tk btl10"] = {
		["sound"] = 53790,
		["description"] = "Tempest Keep Battle 10",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["tk btl11"] = {
		["sound"] = 53791,
		["description"] = "Tempest Keep Battle 11",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["tk btl13"] = {
		["sound"] = 53792,
		["description"] = "Tempest Keep Battle 13",
		["type"] = soundType.MUSIC,
		["length"] = 36
	},
	["tk stg14"] = {
		["sound"] = 53793,
		["description"] = "Tempest Keep stg 14",
		["type"] = soundType.MUSIC,
		["length"] = 11
	},
	["tk stg15"] = {
		["sound"] = 53794,
		["description"] = "Tempest Keep stg 15",
		["type"] = soundType.MUSIC,
		["length"] = 11
	},
	["tk stg16"] = {
		["sound"] = 53795,
		["description"] = "Tempest Keep stg 16",
		["type"] = soundType.MUSIC,
		["length"] = 11
	},
	["tf auchindoun"] = {
		["sound"] = 53796,
		["description"] = "Terrokar Forest Auchindoun",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["tf auchindoun02"] = {
		["sound"] = 53797,
		["description"] = "Terrokar Forest Auchindoun 2",
		["type"] = soundType.MUSIC,
		["length"] = 150
	},
	["tf auchindoun03"] = {
		["sound"] = 53798,
		["description"] = "Terrokar Forest Auchindoun 3",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["tf bone"] = {
		["sound"] = 53799,
		["description"] = "Terrokar Forest Bone",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["tf bone02"] = {
		["sound"] = 53800,
		["description"] = "Terrokar Forest Bone 2",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["tf bone03"] = {
		["sound"] = 53801,
		["description"] = "Terrokar Forest Bone 3",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["tf bone04"] = {
		["sound"] = 53802,
		["description"] = "Terrokar Forest Bone 4",
		["type"] = soundType.MUSIC,
		["length"] = 189
	},
	["tf"] = {
		["sound"] = 53803,
		["description"] = "Terrokar Forest",
		["type"] = soundType.MUSIC,
		["length"] = 150
	},
	["tf02"] = {
		["sound"] = 53804,
		["description"] = "Terrokar Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 190
	},
	["tf03"] = {
		["sound"] = 53805,
		["description"] = "Terrokar Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 187
	},
	["tf shattrath"] = {
		["sound"] = 53806,
		["description"] = "Terrokar Forest Shattrath",
		["type"] = soundType.MUSIC,
		["length"] = 137
	},
	["tf shattrath02"] = {
		["sound"] = 53807,
		["description"] = "Terrokar Forest Shattrath 2",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["tf shattrath03"] = {
		["sound"] = 53808,
		["description"] = "Terrokar Forest Shattrath 3",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["tf shattrath04"] = {
		["sound"] = 53809,
		["description"] = "Terrokar Forest Shattrath 4",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["tf shattrath05"] = {
		["sound"] = 53810,
		["description"] = "Terrokar Forest Shattrath 5",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["tf shattrath06"] = {
		["sound"] = 53811,
		["description"] = "Terrokar Forest Shattrath 6",
		["type"] = soundType.MUSIC,
		["length"] = 137
	},
	["day volcanic"] = {
		["sound"] = 53812,
		["description"] = "Day Volcanic",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["day volcanic02"] = {
		["sound"] = 53813,
		["description"] = "Day Volcanic 2",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["night volcanic"] = {
		["sound"] = 53814,
		["description"] = "Night Volcanic",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["night volcanic02"] = {
		["sound"] = 53815,
		["description"] = "Night Volcanic 2",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["za coilfang"] = {
		["sound"] = 53816,
		["description"] = "Zangarmarsh Coilfang",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["za coilfang02"] = {
		["sound"] = 53817,
		["description"] = "Zangarmarsh Coilfang 2",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["za coilfang03"] = {
		["sound"] = 53818,
		["description"] = "Zangarmarsh Coilfang 3",
		["type"] = soundType.MUSIC,
		["length"] = 109
	},
	["za general"] = {
		["sound"] = 53819,
		["description"] = "Zangarmarsh General",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["za general02"] = {
		["sound"] = 53820,
		["description"] = "Zangarmarsh General 2",
		["type"] = soundType.MUSIC,
		["length"] = 120
	},
	["za general03"] = {
		["sound"] = 53821,
		["description"] = "Zangarmarsh General 3",
		["type"] = soundType.MUSIC,
		["length"] = 59
	},
	["za general04"] = {
		["sound"] = 53822,
		["description"] = "Zangarmarsh General 4",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["za general05"] = {
		["sound"] = 53823,
		["description"] = "Zangarmarsh General 5",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["za general06"] = {
		["sound"] = 53824,
		["description"] = "Zangarmarsh General 6",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["zul amb10"] = {
		["sound"] = 53825,
		["description"] = "Zul'Aman Ambience 10",
		["type"] = soundType.MUSIC,
		["length"] = 113
	},
	["zul amb11"] = {
		["sound"] = 53826,
		["description"] = "Zul'Aman Ambience 11",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["zul amb12"] = {
		["sound"] = 53827,
		["description"] = "Zul'Aman Ambience 12",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["zul amb13"] = {
		["sound"] = 53828,
		["description"] = "Zul'Aman Ambience 13",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["zul amb14"] = {
		["sound"] = 53829,
		["description"] = "Zul'Aman Ambience 14",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["zul amb15"] = {
		["sound"] = 53830,
		["description"] = "Zul'Aman Ambience 15",
		["type"] = soundType.MUSIC,
		["length"] = 113
	},
	["zul btl11"] = {
		["sound"] = 53831,
		["description"] = "Zul'Aman Battle 11",
		["type"] = soundType.MUSIC,
		["length"] = 136
	},
	["zul btl12"] = {
		["sound"] = 53832,
		["description"] = "Zul'Aman Battle 12",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["zul btl13"] = {
		["sound"] = 53833,
		["description"] = "Zul'Aman Battle 13",
		["type"] = soundType.MUSIC,
		["length"] = 40
	},
	["zul btl14"] = {
		["sound"] = 53834,
		["description"] = "Zul'Aman Battle 14",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["zul btl15"] = {
		["sound"] = 53835,
		["description"] = "Zul'Aman Battle 15",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["zul vct10"] = {
		["sound"] = 53836,
		["description"] = "Zul'Aman Victory 10",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["hf day"] = {
		["sound"] = 116821,
		["description"] = "Howling Fjord Day",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["hf day02"] = {
		["sound"] = 116822,
		["description"] = "Howling Fjord Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["hf day03"] = {
		["sound"] = 116823,
		["description"] = "Howling Fjord Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["hf day04"] = {
		["sound"] = 116824,
		["description"] = "Howling Fjord Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["hf day05"] = {
		["sound"] = 116825,
		["description"] = "Howling Fjord Day 5",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["hf day06"] = {
		["sound"] = 116826,
		["description"] = "Howling Fjord Day 6",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["hf day07"] = {
		["sound"] = 116827,
		["description"] = "Howling Fjord Day 7",
		["type"] = soundType.MUSIC,
		["length"] = 149
	},
	["hf night"] = {
		["sound"] = 116828,
		["description"] = "Howling Fjord Night",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["hf night02"] = {
		["sound"] = 116829,
		["description"] = "Howling Fjord Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["hf night03"] = {
		["sound"] = 116830,
		["description"] = "Howling Fjord Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 84
	},
	["hf night04"] = {
		["sound"] = 116831,
		["description"] = "Howling Fjord Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 157
	},
	["gh day"] = {
		["sound"] = 165484,
		["description"] = "Grizzly Hills Day",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["gh day02"] = {
		["sound"] = 165485,
		["description"] = "Grizzly Hills Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 144
	},
	["gh day03"] = {
		["sound"] = 165486,
		["description"] = "Grizzly Hills Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["gh day04"] = {
		["sound"] = 165487,
		["description"] = "Grizzly Hills Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["gh night"] = {
		["sound"] = 165488,
		["description"] = "Grizzly Hills Night",
		["type"] = soundType.MUSIC,
		["length"] = 130
	},
	["gh night02"] = {
		["sound"] = 165489,
		["description"] = "Grizzly Hills Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 141
	},
	["gh day05"] = {
		["sound"] = 165490,
		["description"] = "Grizzly Hills Day 5",
		["type"] = soundType.MUSIC,
		["length"] = 107
	},
	["gh day06"] = {
		["sound"] = 165491,
		["description"] = "Grizzly Hills Day 6",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["gh night03"] = {
		["sound"] = 165492,
		["description"] = "Grizzly Hills Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 101
	},
	["gh night04"] = {
		["sound"] = 165493,
		["description"] = "Grizzly Hills Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 116
	},
	["bf dwarf"] = {
		["sound"] = 228572,
		["description"] = "Brewfest Dwarf",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["bf dwarf2"] = {
		["sound"] = 228573,
		["description"] = "Brewfest Dwarf 2",
		["type"] = soundType.MUSIC,
		["length"] = 115
	},
	["bf dwarf3"] = {
		["sound"] = 228574,
		["description"] = "Brewfest Dwarf 3",
		["type"] = soundType.MUSIC,
		["length"] = 22
	},
	["bf goblin"] = {
		["sound"] = 228575,
		["description"] = "Brewfest Goblin",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["bf goblin2"] = {
		["sound"] = 228576,
		["description"] = "Brewfest Goblin 2",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["bf goblin3"] = {
		["sound"] = 228577,
		["description"] = "Brewfest Goblin 3",
		["type"] = soundType.MUSIC,
		["length"] = 28
	},
	["sp templeofstorms"] = {
		["sound"] = 229735,
		["description"] = "Storm Peaks Temple of Storm",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["an intro"] = {
		["sound"] = 229736,
		["description"] = "Azjol Nerub Intro",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["an intro02"] = {
		["sound"] = 229737,
		["description"] = "Azjol Nerub Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["an intro03"] = {
		["sound"] = 229738,
		["description"] = "Azjol Nerub Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["an intro04"] = {
		["sound"] = 229739,
		["description"] = "Azjol Nerub Intro 4",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["an intro05"] = {
		["sound"] = 229740,
		["description"] = "Azjol Nerub Intro 5",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["an intro06"] = {
		["sound"] = 229741,
		["description"] = "Azjol Nerub Intro 6",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["an intro07"] = {
		["sound"] = 229742,
		["description"] = "Azjol Nerub Intro 7",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["an intro08"] = {
		["sound"] = 229743,
		["description"] = "Azjol Nerub Intro 8",
		["type"] = soundType.MUSIC,
		["length"] = 104
	},
	["an general"] = {
		["sound"] = 229744,
		["description"] = "Azjol Nerub General",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["an general02"] = {
		["sound"] = 229745,
		["description"] = "Azjol Nerub General 2",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["an general03"] = {
		["sound"] = 229746,
		["description"] = "Azjol Nerub General 3",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["an general04"] = {
		["sound"] = 229747,
		["description"] = "Azjol Nerub General 4",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["an general05"] = {
		["sound"] = 229748,
		["description"] = "Azjol Nerub General 5",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["an general06"] = {
		["sound"] = 229749,
		["description"] = "Azjol Nerub General 6",
		["type"] = soundType.MUSIC,
		["length"] = 104
	},
	["an general07"] = {
		["sound"] = 229750,
		["description"] = "Azjol Nerub General 7",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["an general08"] = {
		["sound"] = 229751,
		["description"] = "Azjol Nerub General 8",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["an general09"] = {
		["sound"] = 229752,
		["description"] = "Azjol Nerub General 9",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["an general10"] = {
		["sound"] = 229753,
		["description"] = "Azjol Nerub General 10",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["an general11"] = {
		["sound"] = 229754,
		["description"] = "Azjol Nerub General 11",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["an general12"] = {
		["sound"] = 229755,
		["description"] = "Azjol Nerub General 12",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["an general13"] = {
		["sound"] = 229756,
		["description"] = "Azjol Nerub General 13",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["an general14"] = {
		["sound"] = 229757,
		["description"] = "Azjol Nerub General 14",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["an general15"] = {
		["sound"] = 229758,
		["description"] = "Azjol Nerub General 15",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["an general16"] = {
		["sound"] = 229759,
		["description"] = "Azjol Nerub General 16",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["bo coldarra"] = {
		["sound"] = 229760,
		["description"] = "Borean Tundra Coldarra",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["bo coldarra02"] = {
		["sound"] = 229761,
		["description"] = "Borean Tundra Coldarra 2",
		["type"] = soundType.MUSIC,
		["length"] = 63
	},
	["bo coldarra03"] = {
		["sound"] = 229762,
		["description"] = "Borean Tundra Coldarra 3",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["bo day05"] = {
		["sound"] = 229763,
		["description"] = "Borean Tundra Day 5",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["bo day06"] = {
		["sound"] = 229764,
		["description"] = "Borean Tundra Day 6",
		["type"] = soundType.MUSIC,
		["length"] = 115
	},
	["bo day07"] = {
		["sound"] = 229765,
		["description"] = "Borean Tundra Day 7",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["bo day08"] = {
		["sound"] = 229766,
		["description"] = "Borean Tundra Day 8",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["bo night05"] = {
		["sound"] = 229767,
		["description"] = "Borean Tundra Night 5",
		["type"] = soundType.MUSIC,
		["length"] = 77
	},
	["bo night06"] = {
		["sound"] = 229768,
		["description"] = "Borean Tundra Night 6",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["bo night07"] = {
		["sound"] = 229769,
		["description"] = "Borean Tundra Night 7",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["bo night08"] = {
		["sound"] = 229770,
		["description"] = "Borean Tundra Night 8",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["bo geyserfield"] = {
		["sound"] = 229771,
		["description"] = "Borean Tundra Geyser Field",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["bo geyserfield02"] = {
		["sound"] = 229772,
		["description"] = "Borean Tundra Geyser Field 2",
		["type"] = soundType.MUSIC,
		["length"] = 48
	},
	["bo geyserfield03"] = {
		["sound"] = 229773,
		["description"] = "Borean Tundra Geyser Field 3",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["bo riplashday"] = {
		["sound"] = 229774,
		["description"] = "Borean Tundra Riplash Ruins Day",
		["type"] = soundType.MUSIC,
		["length"] = 151
	},
	["bo riplashday02"] = {
		["sound"] = 229775,
		["description"] = "Borean Tundra Riplash Ruins Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 186
	},
	["bo riplashday03"] = {
		["sound"] = 229776,
		["description"] = "Borean Tundra Riplash Ruins Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 161
	},
	["bo riplashintro"] = {
		["sound"] = 229777,
		["description"] = "Borean Tundra Riplash Ruins Intro",
		["type"] = soundType.MUSIC,
		["length"] = 153
	},
	["bo riplashintro02"] = {
		["sound"] = 229778,
		["description"] = "Borean Tundra Riplash Ruins Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 177
	},
	["bo riplashnight"] = {
		["sound"] = 229779,
		["description"] = "Borean Tundra Riplash Ruins Night",
		["type"] = soundType.MUSIC,
		["length"] = 159
	},
	["bo riplashnight02"] = {
		["sound"] = 229780,
		["description"] = "Borean Tundra Riplash Ruins Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["bo riplashnight03"] = {
		["sound"] = 229781,
		["description"] = "Borean Tundra Riplash Ruins Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["bo riplashnight04"] = {
		["sound"] = 229782,
		["description"] = "Borean Tundra Riplash Ruins Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["ca day"] = {
		["sound"] = 229783,
		["description"] = "Chamber of the Aspects Day",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["ca day02"] = {
		["sound"] = 229784,
		["description"] = "Chamber of the Aspects Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["ca day03"] = {
		["sound"] = 229785,
		["description"] = "Chamber of the Aspects Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["ca day04"] = {
		["sound"] = 229786,
		["description"] = "Chamber of the Aspects Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["ca night"] = {
		["sound"] = 229787,
		["description"] = "Chamber of the Aspects Night",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["ca night02"] = {
		["sound"] = 229788,
		["description"] = "Chamber of the Aspects Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["ca night03"] = {
		["sound"] = 229789,
		["description"] = "Chamber of the Aspects Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["ca night04"] = {
		["sound"] = 229790,
		["description"] = "Chamber of the Aspects Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["ca general"] = {
		["sound"] = 229791,
		["description"] = "Chamber of the Aspects General",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["ca general02"] = {
		["sound"] = 229792,
		["description"] = "Chamber of the Aspects General 2",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["ca introday"] = {
		["sound"] = 229793,
		["description"] = "Chamber of the Aspects Intro Day",
		["type"] = soundType.MUSIC,
		["length"] = 73
	},
	["ca intronight"] = {
		["sound"] = 229794,
		["description"] = "Chamber of the Aspects Intro Night",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["cs"] = {
		["sound"] = 229795,
		["description"] = "Crystalsong Forest",
		["type"] = soundType.MUSIC,
		["length"] = 113
	},
	["cs 2"] = {
		["sound"] = 229796,
		["description"] = "Crystalsong Forest 2",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["cs 3"] = {
		["sound"] = 229797,
		["description"] = "Crystalsong Forest 3",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["cs 4"] = {
		["sound"] = 229798,
		["description"] = "Crystalsong Forest 4",
		["type"] = soundType.MUSIC,
		["length"] = 113
	},
	["cs 5"] = {
		["sound"] = 229799,
		["description"] = "Crystalsong Forest 5",
		["type"] = soundType.MUSIC,
		["length"] = 107
	},
	["dc"] = {
		["sound"] = 229800,
		["description"] = "Dalaran City",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["dc 2"] = {
		["sound"] = 229801,
		["description"] = "Dalaran City 2",
		["type"] = soundType.MUSIC,
		["length"] = 42
	},
	["dc 3"] = {
		["sound"] = 229802,
		["description"] = "Dalaran City 3",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["dc 4"] = {
		["sound"] = 229803,
		["description"] = "Dalaran City 4",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["dc intro"] = {
		["sound"] = 229804,
		["description"] = "Dalaran City Intro",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["dc sewer"] = {
		["sound"] = 229805,
		["description"] = "Dalaran City Sewer",
		["type"] = soundType.MUSIC,
		["length"] = 66
	},
	["dc sewer2"] = {
		["sound"] = 229806,
		["description"] = "Dalaran City Sewer 2",
		["type"] = soundType.MUSIC,
		["length"] = 101
	},
	["dc sewer3"] = {
		["sound"] = 229807,
		["description"] = "Dalaran City Sewer 3",
		["type"] = soundType.MUSIC,
		["length"] = 72
	},
	["dc sewer4"] = {
		["sound"] = 229808,
		["description"] = "Dalaran City Sewer 4",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["dc spire"] = {
		["sound"] = 229809,
		["description"] = "Dalaran City Spire",
		["type"] = soundType.MUSIC,
		["length"] = 91
	},
	["db intro"] = {
		["sound"] = 229810,
		["description"] = "Dragon Blight Intro",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["db intro2"] = {
		["sound"] = 229811,
		["description"] = "Dragon Blight Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db intro3"] = {
		["sound"] = 229812,
		["description"] = "Dragon Blight Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["db intro4"] = {
		["sound"] = 229813,
		["description"] = "Dragon Blight Intro 4",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["db day5"] = {
		["sound"] = 229814,
		["description"] = "Dragon Blight Day 5",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db day6"] = {
		["sound"] = 229815,
		["description"] = "Dragon Blight Day 6",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db day7"] = {
		["sound"] = 229816,
		["description"] = "Dragon Blight Day 7",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db day8"] = {
		["sound"] = 229817,
		["description"] = "Dragon Blight Day 8",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db night5"] = {
		["sound"] = 229818,
		["description"] = "Dragon Blight Night 5",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db night6"] = {
		["sound"] = 229819,
		["description"] = "Dragon Blight Night 6",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["db night7"] = {
		["sound"] = 229820,
		["description"] = "Dragon Blight Night 7",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db night8"] = {
		["sound"] = 229821,
		["description"] = "Dragon Blight Night 8",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["db tuskinduleday"] = {
		["sound"] = 229822,
		["description"] = "Dragon Blight Tusk Indule Day",
		["type"] = soundType.MUSIC,
		["length"] = 129
	},
	["db tuskinduleday2"] = {
		["sound"] = 229823,
		["description"] = "Dragon Blight Tusk Indule Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["eh assault"] = {
		["sound"] = 229824,
		["description"] = "Ebon Hold Assault",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["eh assault2"] = {
		["sound"] = 229825,
		["description"] = "Ebon Hold Assault 2",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["eh assault3"] = {
		["sound"] = 229826,
		["description"] = "Ebon Hold Assault 3",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["eh assault4"] = {
		["sound"] = 229827,
		["description"] = "Ebon Hold Assault 4",
		["type"] = soundType.MUSIC,
		["length"] = 67
	},
	["eh assault5"] = {
		["sound"] = 229828,
		["description"] = "Ebon Hold Assault 5",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["eh assault6"] = {
		["sound"] = 229829,
		["description"] = "Ebon Hold Assault 6",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["eh assault7"] = {
		["sound"] = 229830,
		["description"] = "Ebon Hold Assault 7",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["eh"] = {
		["sound"] = 229831,
		["description"] = "Ebon Hold",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["eh 2"] = {
		["sound"] = 229832,
		["description"] = "Ebon Hold 2",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["eh 3"] = {
		["sound"] = 229833,
		["description"] = "Ebon Hold 3",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["gh intro"] = {
		["sound"] = 229834,
		["description"] = "Grizlly Hills Intro",
		["type"] = soundType.MUSIC,
		["length"] = 284
	},
	["gh intro2"] = {
		["sound"] = 229835,
		["description"] = "Grizlly Hills Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 149
	},
	["gh day7"] = {
		["sound"] = 229836,
		["description"] = "Grizlly Hills Day 7",
		["type"] = soundType.MUSIC,
		["length"] = 141
	},
	["gh day8"] = {
		["sound"] = 229837,
		["description"] = "Grizlly Hills Day 8",
		["type"] = soundType.MUSIC,
		["length"] = 137
	},
	["gh day9"] = {
		["sound"] = 229838,
		["description"] = "Grizlly Hills Day 9",
		["type"] = soundType.MUSIC,
		["length"] = 178
	},
	["gh day10"] = {
		["sound"] = 229839,
		["description"] = "Grizlly Hills Day 10",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["gh day11"] = {
		["sound"] = 229840,
		["description"] = "Grizlly Hills Day 11",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["gh day12"] = {
		["sound"] = 229841,
		["description"] = "Grizlly Hills Day 12",
		["type"] = soundType.MUSIC,
		["length"] = 155
	},
	["gh day13"] = {
		["sound"] = 229842,
		["description"] = "Grizlly Hills Day 13",
		["type"] = soundType.MUSIC,
		["length"] = 155
	},
	["gh day14"] = {
		["sound"] = 229843,
		["description"] = "Grizlly Hills Day 14",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["gh day15"] = {
		["sound"] = 229844,
		["description"] = "Grizlly Hills Day 15",
		["type"] = soundType.MUSIC,
		["length"] = 148
	},
	["gh night3"] = {
		["sound"] = 229845,
		["description"] = "Grizlly Hills Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 101
	},
	["gh night4"] = {
		["sound"] = 229846,
		["description"] = "Grizlly Hills Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["gh night5"] = {
		["sound"] = 229847,
		["description"] = "Grizlly Hills Night 5",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["gh night6"] = {
		["sound"] = 229848,
		["description"] = "Grizlly Hills Night 6",
		["type"] = soundType.MUSIC,
		["length"] = 155
	},
	["gh night7"] = {
		["sound"] = 229849,
		["description"] = "Grizlly Hills Night 7",
		["type"] = soundType.MUSIC,
		["length"] = 149
	},
	["gh night8"] = {
		["sound"] = 229850,
		["description"] = "Grizlly Hills Night 8",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["hf dist"] = {
		["sound"] = 229851,
		["description"] = "Howling Fjord Dist",
		["type"] = soundType.MUSIC,
		["length"] = 30
	},
	["hf dist2"] = {
		["sound"] = 229852,
		["description"] = "Howling Fjord Dist 2",
		["type"] = soundType.MUSIC,
		["length"] = 47
	},
	["hf dist3"] = {
		["sound"] = 229853,
		["description"] = "Howling Fjord Dist 3",
		["type"] = soundType.MUSIC,
		["length"] = 52
	},
	["hf dist4"] = {
		["sound"] = 229854,
		["description"] = "Howling Fjord Dist 4",
		["type"] = soundType.MUSIC,
		["length"] = 26
	},
	["hf dist5"] = {
		["sound"] = 229855,
		["description"] = "Howling Fjord Dist 5",
		["type"] = soundType.MUSIC,
		["length"] = 22
	},
	["hf dist6"] = {
		["sound"] = 229856,
		["description"] = "Howling Fjord Dist 6",
		["type"] = soundType.MUSIC,
		["length"] = 41
	},
	["hf dist7"] = {
		["sound"] = 229857,
		["description"] = "Howling Fjord Dist 7",
		["type"] = soundType.MUSIC,
		["length"] = 23
	},
	["icg intro"] = {
		["sound"] = 229858,
		["description"] = "Ice Crown Glacier Intro",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["icg intro2"] = {
		["sound"] = 229859,
		["description"] = "Icecrown Glacier Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["icg intro3"] = {
		["sound"] = 229860,
		["description"] = "Icecrown Glacier Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["icg day"] = {
		["sound"] = 229861,
		["description"] = "Icecrown Glacier Day",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["icg day2"] = {
		["sound"] = 229862,
		["description"] = "Icecrown Glacier Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 101
	},
	["icg day3"] = {
		["sound"] = 229863,
		["description"] = "Icecrown Glacier Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["icg day4"] = {
		["sound"] = 229864,
		["description"] = "Icecrown Glacier Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["icg night"] = {
		["sound"] = 229865,
		["description"] = "Icecrown Glacier Night",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["icg night2"] = {
		["sound"] = 229866,
		["description"] = "Icecrown Glacier Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["icg night3"] = {
		["sound"] = 229867,
		["description"] = "Icecrown Glacier Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["icg night4"] = {
		["sound"] = 229868,
		["description"] = "Icecrown Glacier Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 64
	},
	["icg night5"] = {
		["sound"] = 229869,
		["description"] = "Icecrown Glacier Night 5",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["lwg contested"] = {
		["sound"] = 229870,
		["description"] = "Lake Wintergrasp Contested",
		["type"] = soundType.MUSIC,
		["length"] = 40
	},
	["lwg contested2"] = {
		["sound"] = 229871,
		["description"] = "Lake Wintergrasp Contested 2",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["lwg contested3"] = {
		["sound"] = 229872,
		["description"] = "Lake Wintergrasp Contested 3",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["lwg"] = {
		["sound"] = 229873,
		["description"] = "Lake Wintergrasp",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["lwg 2"] = {
		["sound"] = 229874,
		["description"] = "Lake Wintergrasp 2",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["lwg 3"] = {
		["sound"] = 229875,
		["description"] = "Lake Wintergrasp 3",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["lwg 4"] = {
		["sound"] = 229876,
		["description"] = "Lake Wintergrasp 4",
		["type"] = soundType.MUSIC,
		["length"] = 43
	},
	["lwg 5"] = {
		["sound"] = 229877,
		["description"] = "Lake Wintergrasp 5",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["nx"] = {
		["sound"] = 229878,
		["description"] = "Nexus",
		["type"] = soundType.MUSIC,
		["length"] = 76
	},
	["nx 2"] = {
		["sound"] = 229879,
		["description"] = "Nexus 2",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["nx 3"] = {
		["sound"] = 229880,
		["description"] = "Nexus 3",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["nx 4"] = {
		["sound"] = 229881,
		["description"] = "Nexus 4",
		["type"] = soundType.MUSIC,
		["length"] = 107
	},
	["nx 5"] = {
		["sound"] = 229882,
		["description"] = "Nexus 5",
		["type"] = soundType.MUSIC,
		["length"] = 90
	},
	["nx hail"] = {
		["sound"] = 229883,
		["description"] = "Nexus Hail",
		["type"] = soundType.MUSIC,
		["length"] = 57
	},
	["nx hail2"] = {
		["sound"] = 229884,
		["description"] = "Nexus Hail",
		["type"] = soundType.MUSIC,
		["length"] = 65
	},
	["nx pulse"] = {
		["sound"] = 229885,
		["description"] = "Nexus Pulse",
		["type"] = soundType.MUSIC,
		["length"] = 60
	},
	["nx pulse2"] = {
		["sound"] = 229886,
		["description"] = "Nexus Pulse 2",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["nx quiet"] = {
		["sound"] = 229887,
		["description"] = "Nexus Quiet",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["nx quiet2"] = {
		["sound"] = 229888,
		["description"] = "Nexus Quiet 2",
		["type"] = soundType.MUSIC,
		["length"] = 111
	},
	["nx quiet3"] = {
		["sound"] = 229889,
		["description"] = "Nexus Quiet 3",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["nx quiet4"] = {
		["sound"] = 229890,
		["description"] = "Nexus Quiet 4",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["nr irondwarfday"] = {
		["sound"] = 229891,
		["description"] = "Northrend Irondwarf Day",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["nr irondwarfnight"] = {
		["sound"] = 229892,
		["description"] = "Northrend Irondwarf Night",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["nr irondwarfdark"] = {
		["sound"] = 229893,
		["description"] = "Northrend Irondwarf Dark",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["nr irondwarfday2"] = {
		["sound"] = 229894,
		["description"] = "Northrend Irondwarf Day 2",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["nr irondwarfnight2"] = {
		["sound"] = 229895,
		["description"] = "Northrend Irondwarf Night 2",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["nr irondwarf"] = {
		["sound"] = 229896,
		["description"] = "Northrend Irondwarf",
		["type"] = soundType.MUSIC,
		["length"] = 163
	},
	["nr irondwarfday3"] = {
		["sound"] = 229897,
		["description"] = "Northrend Irondwarf Day 3",
		["type"] = soundType.MUSIC,
		["length"] = 42
	},
	["nr irondwarfnight3"] = {
		["sound"] = 229898,
		["description"] = "Northrend Irondwarf Night 3",
		["type"] = soundType.MUSIC,
		["length"] = 42
	},
	["nr irondwarf2"] = {
		["sound"] = 229899,
		["description"] = "Northrend Irondwarf 2",
		["type"] = soundType.MUSIC,
		["length"] = 42
	},
	["nr irondwarfdark2"] = {
		["sound"] = 229900,
		["description"] = "Northrend Irondwarf Dark 2",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["nr irondwarfday4"] = {
		["sound"] = 229901,
		["description"] = "Northrend Irondwarf Day 4",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["nr irondwarfnight4"] = {
		["sound"] = 229902,
		["description"] = "Northrend Irondwarf Night 4",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["nr irondwarfdark3"] = {
		["sound"] = 229903,
		["description"] = "Northrend Irondwarf Dark 3",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["sotp"] = {
		["sound"] = 3931650,
		["description"] = "Seat of the Primus",
		["type"] = soundType.MUSIC,
		["length"] = 181
	},
	["shadow ib2"] = {
		["sound"] = 3931392,
		["description"] = "Shadow in Between 2",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["shadow ib"] = {
		["sound"] = 3931390,
		["description"] = "Shadow in Between",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["bastion"] = {
		["sound"] = 3552890,
		["description"] = "Bastion",
		["type"] = soundType.MUSIC,
		["length"] = 163
	},
	["bastion 2"] = {
		["sound"] = 3552892,
		["description"] = "Bastion 2",
		["type"] = soundType.MUSIC,
		["length"] = 164
	},
	["bastion aspirantsjourney"] = {
		["sound"] = 3552894,
		["description"] = "Bastion Aspirants Journey",
		["type"] = soundType.MUSIC,
		["length"] = 164
	},
	["bastion tobekyrian2"] = {
		["sound"] = 3552896,
		["description"] = "Bastion to be Kyrian 2",
		["type"] = soundType.MUSIC,
		["length"] = 353
	},
	["bastion tobekyrian"] = {
		["sound"] = 3552898,
		["description"] = "Bastion to be Kyrian",
		["type"] = soundType.MUSIC,
		["length"] = 356
	},
	["npe human"] = {
		["sound"] = 3850459,
		["description"] = "New Player Experience Human",
		["type"] = soundType.MUSIC,
		["length"] = 139
	},
	["npe human2"] = {
		["sound"] = 3850461,
		["description"] = "New Player Experience Human 2",
		["type"] = soundType.MUSIC,
		["length"] = 139
	},
	["npe human3"] = {
		["sound"] = 3850463,
		["description"] = "New Player Experience Human 3",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["npe human4"] = {
		["sound"] = 3850465,
		["description"] = "New Player Experience Human 4",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["npe human5"] = {
		["sound"] = 3850467,
		["description"] = "New Player Experience Human 5",
		["type"] = soundType.MUSIC,
		["length"] = 141
	},
	["npe orc"] = {
		["sound"] = 3850469,
		["description"] = "New Player Experience Orc",
		["type"] = soundType.MUSIC,
		["length"] = 127
	},
	["npe orc2"] = {
		["sound"] = 3850471,
		["description"] = "New Player Experience Orc 2",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["npe orc3"] = {
		["sound"] = 3850473,
		["description"] = "New Player Experience Orc 3",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["npe orc4"] = {
		["sound"] = 3850475,
		["description"] = "New Player Experience Orc 4",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["npe orc5"] = {
		["sound"] = 3850477,
		["description"] = "New Player Experience Orc 5",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["npe orc5"] = {
		["sound"] = 3850479,
		["description"] = "New Player Experience Orc 6",
		["type"] = soundType.MUSIC,
		["length"] = 150
	},
	["sd ambienttension"] = {
		["sound"] = 3850481,
		["description"] = "Shadow Domination Ambient Tension",
		["type"] = soundType.MUSIC,
		["length"] = 69
	},
	["sd ambienttension2"] = {
		["sound"] = 3850483,
		["description"] = "Shadow Domination Ambient Tension 2",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["sd ambienttension3"] = {
		["sound"] = 3850485,
		["description"] = "Shadow Domination Ambient Tension 3",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["sd battle"] = {
		["sound"] = 3850487,
		["description"] = "Shadow Domination Battle",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["sd battle2"] = {
		["sound"] = 3850489,
		["description"] = "Shadow Domination Battle 2",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["sd battle3"] = {
		["sound"] = 3850491,
		["description"] = "Shadow Domination Battle 3",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["sd battle4"] = {
		["sound"] = 3850493,
		["description"] = "Shadow Domination Battle 4",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["sd"] = {
		["sound"] = 3850495,
		["description"] = "Shadow Domination",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["shadow sylvanasfreewill"] = {
		["sound"] = 3850497,
		["description"] = "Shadow Sylvanas free Will",
		["type"] = soundType.MUSIC,
		["length"] = 139
	},
	["shadow sylvanasfreewill2"] = {
		["sound"] = 3850499,
		["description"] = "Shadow Sylvanas free Will 2",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["shadow sylvanasfreewill3"] = {
		["sound"] = 3850501,
		["description"] = "Shadow Sylvanas free Will 3",
		["type"] = soundType.MUSIC,
		["length"] = 116
	},
	["shadow sylvanasfreewill4"] = {
		["sound"] = 3850503,
		["description"] = "Shadow Sylvanas free Will 4",
		["type"] = soundType.MUSIC,
		["length"] = 143
	},
	["shadow sylvanasfreewill5"] = {
		["sound"] = 3850505,
		["description"] = "Shadow Sylvanas free Will 5",
		["type"] = soundType.MUSIC,
		["length"] = 172
	},
	["shadow unbrokenwillaction"] = {
		["sound"] = 3850507,
		["description"] = "Shadow unbroken Will Action",
		["type"] = soundType.MUSIC,
		["length"] = 86
	},
	["shadow unbrokenwillaction2"] = {
		["sound"] = 3850509,
		["description"] = "Shadow unbroken Will Action 2",
		["type"] = soundType.MUSIC,
		["length"] = 32
	},
	["shadow unbrokenwillaction3"] = {
		["sound"] = 3850511,
		["description"] = "Shadow unbroken Will Action 3",
		["type"] = soundType.MUSIC,
		["length"] = 52
	},
	["shadow unbrokenwillaction4"] = {
		["sound"] = 3850513,
		["description"] = "Shadow unbroken Will Action 4",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["shadow unbrokenwillambient"] = {
		["sound"] = 3850515,
		["description"] = "Shadow unbroken Will Ambient",
		["type"] = soundType.MUSIC,
		["length"] = 62
	},
	["shadow unbrokenwillambient2"] = {
		["sound"] = 3850517,
		["description"] = "Shadow unbroken Will Ambient 2",
		["type"] = soundType.MUSIC,
		["length"] = 56
	},
	["shadow unbrokenwillambient3"] = {
		["sound"] = 3850519,
		["description"] = "Shadow unbroken Will Ambient 3",
		["type"] = soundType.MUSIC,
		["length"] = 52
	},
	["shadow unbrokenwillambient4"] = {
		["sound"] = 3850521,
		["description"] = "Shadow unbroken Will Ambient 4",
		["type"] = soundType.MUSIC,
		["length"] = 132
	},
	["shadow unbrokenwillambient5"] = {
		["sound"] = 3850523,
		["description"] = "Shadow unbroken Will Ambient 5",
		["type"] = soundType.MUSIC,
		["length"] = 131
	},
	["shadow unbrokenwillambient6"] = {
		["sound"] = 3850523,
		["description"] = "Shadow unbroken Will Ambient 6",
		["type"] = soundType.MUSIC,
		["length"] = 129
	},
	["rtc alliance"] = {
		["sound"] = 3850539,
		["description"] = "RTC Alliance",
		["type"] = soundType.MUSIC,
		["length"] = 37
	},
	["rtc horde"] = {
		["sound"] = 3850541,
		["description"] = "RTC Horde",
		["type"] = soundType.MUSIC,
		["length"] = 37
	},
	["rtc alliance2"] = {
		["sound"] = 3850543,
		["description"] = "RTC Alliance 2",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["rtc horde2"] = {
		["sound"] = 3850545,
		["description"] = "RTC Horde 2",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["rtc sl"] = {
		["sound"] = 3850547,
		["description"] = "RTC Shadowlands",
		["type"] = soundType.MUSIC,
		["length"] = 37
	},
	["rtc alliance3"] = {
		["sound"] = 3850549,
		["description"] = "RTC Alliance 3",
		["type"] = soundType.MUSIC,
		["length"] = 46
	},
	["rtc horde3"] = {
		["sound"] = 3850551,
		["description"] = "RTC Horde 3",
		["type"] = soundType.MUSIC,
		["length"] = 45
	},
	["sl ttrotwmaintitle"] = {
		["sound"] = 3850553,
		["description"] = "Shadowlands through the Roof of the World - Main Title",
		["type"] = soundType.MUSIC,
		["length"] = 684
	},
	["aw o"] = {
		["sound"] = 3853182,
		["description"] = "Ardenweald Oblivion",
		["type"] = soundType.MUSIC,
		["length"] = 155
	},
	["aw oa"] = {
		["sound"] = 3853184,
		["description"] = "Ardenweald Oblivion Ambient",
		["type"] = soundType.MUSIC,
		["length"] = 58
	},
	["aw oa2"] = {
		["sound"] = 3853186,
		["description"] = "Ardenweald Oblivion Ambient 2",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["aw oa3"] = {
		["sound"] = 3853188,
		["description"] = "Ardenweald Oblivion Ambient 3",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["aw oa4"] = {
		["sound"] = 3853190,
		["description"] = "Ardenweald Oblivion Ambient 4",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["aw oa5"] = {
		["sound"] = 3853192,
		["description"] = "Ardenweald Oblivion Ambient 5",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["aw o2"] = {
		["sound"] = 3853194,
		["description"] = "Ardenweald Oblivion 2",
		["type"] = soundType.MUSIC,
		["length"] = 129
	},
	["aw o3"] = {
		["sound"] = 3853196,
		["description"] = "Ardenweald Oblivion 3",
		["type"] = soundType.MUSIC,
		["length"] = 99
	},
	["aw od"] = {
		["sound"] = 3853198,
		["description"] = "Ardenweald Oblivion Dark",
		["type"] = soundType.MUSIC,
		["length"] = 92
	},
	["aw od2"] = {
		["sound"] = 3853200,
		["description"] = "Ardenweald Oblivion Dark 2",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["aw od3"] = {
		["sound"] = 3853202,
		["description"] = "Ardenweald Oblivion Dark 3",
		["type"] = soundType.MUSIC,
		["length"] = 135
	},
	["aw od4"] = {
		["sound"] = 3853204,
		["description"] = "Ardenweald Oblivion Dark 4",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["aw od5"] = {
		["sound"] = 3853206,
		["description"] = "Ardenweald Oblivion Dark 5",
		["type"] = soundType.MUSIC,
		["length"] = 155
	},
	["aw odsting"] = {
		["sound"] = 3853208,
		["description"] = "Ardenweald Oblivion Dark Sting",
		["type"] = soundType.MUSIC,
		["length"] = 25
	},
	["aw odsting2"] = {
		["sound"] = 3853210,
		["description"] = "Ardenweald Oblivion Dark Sting 2",
		["type"] = soundType.MUSIC,
		["length"] = 21
	},
	["aw odesolate"] = {
		["sound"] = 3853212,
		["description"] = "Ardenweald Oblivion Desolate",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["aw odesolate2"] = {
		["sound"] = 3853214,
		["description"] = "Ardenweald Oblivion Desolate 2",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["aw odesolate3"] = {
		["sound"] = 3853216,
		["description"] = "Ardenweald Oblivion Desolate 3",
		["type"] = soundType.MUSIC,
		["length"] = 97
	},
	["aw odesolate4"] = {
		["sound"] = 3853218,
		["description"] = "Ardenweald Oblivion Desolate 4",
		["type"] = soundType.MUSIC,
		["length"] = 71
	},
	["aw odesolate5"] = {
		["sound"] = 3853220,
		["description"] = "Ardenweald Oblivion Desolate 5",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["aw odesolate6"] = {
		["sound"] = 3853222,
		["description"] = "Ardenweald Oblivion Desolate 6",
		["type"] = soundType.MUSIC,
		["length"] = 149
	},
	["aw odesolatesting"] = {
		["sound"] = 3853224,
		["description"] = "Ardenweald Oblivion Desolate Sting",
		["type"] = soundType.MUSIC,
		["length"] = 21
	},
	["aw odesolatesting2"] = {
		["sound"] = 3853226,
		["description"] = "Ardenweald Oblivion Desolate Sting 2",
		["type"] = soundType.MUSIC,
		["length"] = 19
	},
	["aw odesolatesting3"] = {
		["sound"] = 3853228,
		["description"] = "Ardenweald Oblivion Desolate Sting 3",
		["type"] = soundType.MUSIC,
		["length"] = 27
	},
	["aw odesolatesting4"] = {
		["sound"] = 3853230,
		["description"] = "Ardenweald Oblivion Desolate Sting 4",
		["type"] = soundType.MUSIC,
		["length"] = 20
	},
	["aw o4"] = {
		["sound"] = 3853232,
		["description"] = "Ardenweald Oblivion 4",
		["type"] = soundType.MUSIC,
		["length"] = 215
	},
	["aw rebirth"] = {
		["sound"] = 3853234,
		["description"] = "Ardenweald Rebirth",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["aw rebirth2"] = {
		["sound"] = 3853236,
		["description"] = "Ardenweald Rebirth 2",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["aw rebirth3"] = {
		["sound"] = 3853238,
		["description"] = "Ardenweald Rebirth 3",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["aw rebirth4"] = {
		["sound"] = 3853240,
		["description"] = "Ardenweald Rebirth 4",
		["type"] = soundType.MUSIC,
		["length"] = 36
	},
	["aw rebirth5"] = {
		["sound"] = 3853242,
		["description"] = "Ardenweald Rebirth 5",
		["type"] = soundType.MUSIC,
		["length"] = 74
	},
	["aw rebirth6"] = {
		["sound"] = 3853244,
		["description"] = "Ardenweald Rebirth 6",
		["type"] = soundType.MUSIC,
		["length"] = 159
	},
	["aw rebirth7"] = {
		["sound"] = 3853246,
		["description"] = "Ardenweald Rebirth 7",
		["type"] = soundType.MUSIC,
		["length"] = 159
	},
	["aw rebirthlullabyrelaxed"] = {
		["sound"] = 3853248,
		["description"] = "Ardenweald Rebirth Lullaby Relaxed",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["aw rebirthlullabyrelaxed2"] = {
		["sound"] = 3853250,
		["description"] = "Ardenweald Rebirth Lullaby Relaxed 2",
		["type"] = soundType.MUSIC,
		["length"] = 70
	},
	["aw rebirthlullabyrelaxed3"] = {
		["sound"] = 3853252,
		["description"] = "Ardenweald Rebirth Lullaby Relaxed 3",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["aw rebirthlullabyrelaxed4"] = {
		["sound"] = 3853254,
		["description"] = "Ardenweald Rebirth Lullaby Relaxed 4",
		["type"] = soundType.MUSIC,
		["length"] = 81
	},
	["aw rebirthlullabyrelaxed5"] = {
		["sound"] = 3853256,
		["description"] = "Ardenweald Rebirth Lullaby Relaxed 5",
		["type"] = soundType.MUSIC,
		["length"] = 98
	},
	["aw rebirthlullaby"] = {
		["sound"] = 3853258,
		["description"] = "Ardenweald Rebirth Lullaby",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["aw rebirthlullaby"] = {
		["sound"] = 3853258,
		["description"] = "Ardenweald Rebirth Lullaby",
		["type"] = soundType.MUSIC,
		["length"] = 83
	},
	["aw rebirthlullaby2"] = {
		["sound"] = 3853260,
		["description"] = "Ardenweald Rebirth Lullaby 2",
		["type"] = soundType.MUSIC,
		["length"] = 110
	},
	["aw rebirthlullaby3"] = {
		["sound"] = 3853262,
		["description"] = "Ardenweald Rebirth Lullaby 3",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["aw rebirthlullabysting"] = {
		["sound"] = 3853264,
		["description"] = "Ardenweald Rebirth Lullaby Sting",
		["type"] = soundType.MUSIC,
		["length"] = 20
	},
	["aw rebirthlullabysting2"] = {
		["sound"] = 3853266,
		["description"] = "Ardenweald Rebirth Lullaby Sting 2",
		["type"] = soundType.MUSIC,
		["length"] = 18
	},
	["aw rebirthlullabysting3"] = {
		["sound"] = 3853268,
		["description"] = "Ardenweald Rebirth Lullaby Sting 3",
		["type"] = soundType.MUSIC,
		["length"] = 20
	},
	["aw loamuehzala"] = {
		["sound"] = 3853270,
		["description"] = "Ardenweald Loa Muehzala",
		["type"] = soundType.MUSIC,
		["length"] = 144
	},
	["aw loamuehzala2"] = {
		["sound"] = 3853272,
		["description"] = "Ardenweald Loa Muehzala 2",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["aw loamuehzala3"] = {
		["sound"] = 3853274,
		["description"] = "Ardenweald Loa Muehzala 3",
		["type"] = soundType.MUSIC,
		["length"] = 93
	},
	["aw loamuehzala4"] = {
		["sound"] = 3853276,
		["description"] = "Ardenweald Loa Muehzala 4",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["aw loamuehzala5"] = {
		["sound"] = 3853278,
		["description"] = "Ardenweald Loa Muehzala 5",
		["type"] = soundType.MUSIC,
		["length"] = 106
	},
	["aw loamuehzala6"] = {
		["sound"] = 3853280,
		["description"] = "Ardenweald Loa Muehzala 6",
		["type"] = soundType.MUSIC,
		["length"] = 136
	},
	["aw nightfae"] = {
		["sound"] = 3853282,
		["description"] = "Ardenweald Nightfae",
		["type"] = soundType.MUSIC,
		["length"] = 114
	},
	["aw nightfae2"] = {
		["sound"] = 3853284,
		["description"] = "Ardenweald Nightfae 2",
		["type"] = soundType.MUSIC,
		["length"] = 118
	},
	["aw nightfae3"] = {
		["sound"] = 3853286,
		["description"] = "Ardenweald Nightfae 3",
		["type"] = soundType.MUSIC,
		["length"] = 129
	},
	["aw nightfae4"] = {
		["sound"] = 3853288,
		["description"] = "Ardenweald Nightfae 4",
		["type"] = soundType.MUSIC,
		["length"] = 123
	},
	["aw nightfae5"] = {
		["sound"] = 3853290,
		["description"] = "Ardenweald Nightfae 5",
		["type"] = soundType.MUSIC,
		["length"] = 100
	},
	["aw nightfae6"] = {
		["sound"] = 3853292,
		["description"] = "Ardenweald Nightfae 6",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["aw nightfae7"] = {
		["sound"] = 3853294,
		["description"] = "Ardenweald Nightfae 7",
		["type"] = soundType.MUSIC,
		["length"] = 171
	},
	["aw nightfae8"] = {
		["sound"] = 3853296,
		["description"] = "Ardenweald Nightfae 8",
		["type"] = soundType.MUSIC,
		["length"] = 121
	},
	["aw nightfaeintro"] = {
		["sound"] = 3853298,
		["description"] = "Ardenweald Nightfae Intro",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["aw nightfaeintro2"] = {
		["sound"] = 3853300,
		["description"] = "Ardenweald Nightfae Intro 2",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["aw nightfaeintro3"] = {
		["sound"] = 3853302,
		["description"] = "Ardenweald Nightfae Intro 3",
		["type"] = soundType.MUSIC,
		["length"] = 61
	},
	["aw nightfae9"] = {
		["sound"] = 3853304,
		["description"] = "Ardenweald Nightfae 9",
		["type"] = soundType.MUSIC,
		["length"] = 126
	},
	["aw nightfae10"] = {
		["sound"] = 3853306,
		["description"] = "Ardenweald Nightfae 10",
		["type"] = soundType.MUSIC,
		["length"] = 144
	},
	["aw nightfae11"] = {
		["sound"] = 3853308,
		["description"] = "Ardenweald Nightfae 11",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["aw nightfae12"] = {
		["sound"] = 3853310,
		["description"] = "Ardenweald Nightfae 12",
		["type"] = soundType.MUSIC,
		["length"] = 131
	},
	["aw ncelestial"] = {
		["sound"] = 3853312,
		["description"] = "Ardenweald Nocturne Celestial",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw ncelestial2"] = {
		["sound"] = 3853314,
		["description"] = "Ardenweald Nocturne Celestial 2",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw ncelestial3"] = {
		["sound"] = 3853316,
		["description"] = "Ardenweald Nocturne Celestial 3",
		["type"] = soundType.MUSIC,
		["length"] = 132
	},
	["aw ncelestial4"] = {
		["sound"] = 3853318,
		["description"] = "Ardenweald Nocturne Celestial 4",
		["type"] = soundType.MUSIC,
		["length"] = 132
	},
	["aw ncelestial5"] = {
		["sound"] = 3853320,
		["description"] = "Ardenweald Nocturne Celestial 5",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["aw ncelestial6"] = {
		["sound"] = 3853322,
		["description"] = "Ardenweald Nocturne Celestial 6",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw ncelestial6"] = {
		["sound"] = 3853324,
		["description"] = "Ardenweald Nocturne Celestial 6",
		["type"] = soundType.MUSIC,
		["length"] = 103
	},
	["aw ncelestial7"] = {
		["sound"] = 3853326,
		["description"] = "Ardenweald Nocturne Celestial 7",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["aw ncelestial8"] = {
		["sound"] = 3853328,
		["description"] = "Ardenweald Nocturne Celestial 8",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["aw ncelestial9"] = {
		["sound"] = 3853330,
		["description"] = "Ardenweald Nocturne Celestial 9",
		["type"] = soundType.MUSIC,
		["length"] = 112
	},
	["aw ncelestial10"] = {
		["sound"] = 3853332,
		["description"] = "Ardenweald Nocturne Celestial 10",
		["type"] = soundType.MUSIC,
		["length"] = 124
	},
	["aw ndevious"] = {
		["sound"] = 3853334,
		["description"] = "Ardenweald Nocturne Devious",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw ndevious2"] = {
		["sound"] = 3853336,
		["description"] = "Ardenweald Nocturne Devious2",
		["type"] = soundType.MUSIC,
		["length"] = 89
	},
	["aw ndevious3"] = {
		["sound"] = 3853338,
		["description"] = "Ardenweald Nocturne Devious 3",
		["type"] = soundType.MUSIC,
		["length"] = 68
	},
	["aw ndevious4"] = {
		["sound"] = 3853340,
		["description"] = "Ardenweald Nocturne Devious 4",
		["type"] = soundType.MUSIC,
		["length"] = 88
	},
	["aw ndevious5"] = {
		["sound"] = 3853342,
		["description"] = "Ardenweald Nocturne Devious 5",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["aw ndevious6"] = {
		["sound"] = 3853344,
		["description"] = "Ardenweald Nocturne Devious 6",
		["type"] = soundType.MUSIC,
		["length"] = 78
	},
	["aw ndevious7"] = {
		["sound"] = 3853346,
		["description"] = "Ardenweald Nocturne Devious 7",
		["type"] = soundType.MUSIC,
		["length"] = 95
	},
	["aw ndevious8"] = {
		["sound"] = 3853348,
		["description"] = "Ardenweald Nocturne Devious 8",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw ndevioussting"] = {
		["sound"] = 3853350,
		["description"] = "Ardenweald Nocturne Devious Sting",
		["type"] = soundType.MUSIC,
		["length"] = 17
	},
	["aw ndevioussting2"] = {
		["sound"] = 3853352,
		["description"] = "Ardenweald Nocturne Devious Sting 2",
		["type"] = soundType.MUSIC,
		["length"] = 18
	},
	["aw nhollow"] = {
		["sound"] = 3853354,
		["description"] = "Ardenweald Nocturne Hollow",
		["type"] = soundType.MUSIC,
		["length"] = 160
	},
	["aw nhollow2"] = {
		["sound"] = 3853356,
		["description"] = "Ardenweald Nocturne Hollow 2",
		["type"] = soundType.MUSIC,
		["length"] = 158
	},
	["aw nhollow3"] = {
		["sound"] = 3853358,
		["description"] = "Ardenweald Nocturne Hollow 3",
		["type"] = soundType.MUSIC,
		["length"] = 158
	},
	["aw nhollow4"] = {
		["sound"] = 3853360,
		["description"] = "Ardenweald Nocturne Hollow 4",
		["type"] = soundType.MUSIC,
		["length"] = 156
	},
	["aw nhollow5"] = {
		["sound"] = 3853362,
		["description"] = "Ardenweald Nocturne Hollow 5",
		["type"] = soundType.MUSIC,
		["length"] = 156
	},
	["aw nhollow6"] = {
		["sound"] = 3853364,
		["description"] = "Ardenweald Nocturne Hollow 6",
		["type"] = soundType.MUSIC,
		["length"] = 156
	},
	["aw nhunger"] = {
		["sound"] = 3853366,
		["description"] = "Ardenweald Nocturne Hunger",
		["type"] = soundType.MUSIC,
		["length"] = 135
	},
	["aw nhunger2"] = {
		["sound"] = 3853368,
		["description"] = "Ardenweald Nocturne Hunger 2",
		["type"] = soundType.MUSIC,
		["length"] = 87
	},
	["aw nhunger3"] = {
		["sound"] = 3853370,
		["description"] = "Ardenweald Nocturne Hunger 3",
		["type"] = soundType.MUSIC,
		["length"] = 75
	},
	["aw nhunger4"] = {
		["sound"] = 3853372,
		["description"] = "Ardenweald Nocturne Hunger 4",
		["type"] = soundType.MUSIC,
		["length"] = 18
	},
	["aw nhunger5"] = {
		["sound"] = 3853374,
		["description"] = "Ardenweald Nocturne Hunger 5",
		["type"] = soundType.MUSIC,
		["length"] = 19
	},
	["aw nhunger6"] = {
		["sound"] = 3853376,
		["description"] = "Ardenweald Nocturne Hunger 6",
		["type"] = soundType.MUSIC,
		["length"] = 136
	},
	["aw nmelancholydream"] = {
		["sound"] = 3853378,
		["description"] = "Ardenweald Nocturne Melancholy Dream",
		["type"] = soundType.MUSIC,
		["length"] = 143
	},
	["aw nmelancholydream2"] = {
		["sound"] = 3853380,
		["description"] = "Ardenweald Nocturne Melancholy Dream 2",
		["type"] = soundType.MUSIC,
		["length"] = 143
	},
	["aw nmelancholydream3"] = {
		["sound"] = 3853382,
		["description"] = "Ardenweald Nocturne Melancholy Dream 3",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw nmelancholydream4"] = {
		["sound"] = 3853384,
		["description"] = "Ardenweald Nocturne Melancholy Dream 4",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw nmelancholydream5"] = {
		["sound"] = 3853386,
		["description"] = "Ardenweald Nocturne Melancholy Dream 5",
		["type"] = soundType.MUSIC,
		["length"] = 131
	},
	["aw nmelancholydream6"] = {
		["sound"] = 3853388,
		["description"] = "Ardenweald Nocturne Melancholy Dream 6",
		["type"] = soundType.MUSIC,
		["length"] = 133
	},
	["aw nmelancholydream7"] = {
		["sound"] = 3853390,
		["description"] = "Ardenweald Nocturne Melancholy Dream 7",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw nmelancholydream8"] = {
		["sound"] = 3853392,
		["description"] = "Ardenweald Nocturne Melancholy Dream 8",
		["type"] = soundType.MUSIC,
		["length"] = 122
	},
	["aw nmelancholydream9"] = {
		["sound"] = 3853394,
		["description"] = "Ardenweald Nocturne Melancholy Dream 9",
		["type"] = soundType.MUSIC,
		["length"] = 108
	},
	["aw nmelancholydream10"] = {
		["sound"] = 3853396,
		["description"] = "Ardenweald Nocturne Melancholy Dream 10",
		["type"] = soundType.MUSIC,
		["length"] = 77
	},
	["aw nmelancholydream11"] = {
		["sound"] = 3853398,
		["description"] = "Ardenweald Nocturne Melancholy Dream 11",
		["type"] = soundType.MUSIC,
		["length"] = 102
	},
	["aw nmischief"] = {
		["sound"] = 3853400,
		["description"] = "Ardenweald Nocturne Mischief",
		["type"] = soundType.MUSIC,
		["length"] = 94
	},
	["aw nmischief2"] = {
		["sound"] = 3853402,
		["description"] = "Ardenweald Nocturne Mischief 2",
		["type"] = soundType.MUSIC,
		["length"] = 79
	},
	["aw nmischief3"] = {
		["sound"] = 3853404,
		["description"] = "Ardenweald Nocturne Mischief 3",
		["type"] = soundType.MUSIC,
		["length"] = 82
	},
	["aw nmischief4"] = {
		["sound"] = 3853406,
		["description"] = "Ardenweald Nocturne Mischief 4",
		["type"] = soundType.MUSIC,
		["length"] = 117
	},
	["aw nmischiefharploop"] = {
		["sound"] = 3853408,
		["description"] = "Ardenweald Nocturne Harp Loop",
		["type"] = soundType.MUSIC,
		["length"] = 27
	},
	["aw nmischiefharpsting"] = {
		["sound"] = 3853410,
		["description"] = "Ardenweald Nocturne Harp Sting",
		["type"] = soundType.MUSIC,
		["length"] = 9
	}
}
local commands = {
	[shortcut .. " tracks"] = {
		["description"] = "Displays all sound commands"
	},
	["play [track]"] = {
		["description"] = "Plays that track, get the tracks from /" .. shortcut .." tracks"
	},
	["stop"] = {
		["description"] = "Stopping all started Sounds/Musics"
	},
	["music on"] = {
		["description"] = "Activates music"
	},
	["music off"] = {
		["description"] = "Deactivates music"
	},
	["music toggle"] = {
		["description"] = "Toggles music"
	},
	["music +"] = {
		["description"] = "Increases music volume by 5%"
	},
	["music -"] = {
		["description"] = "Decreases music volume by 5%"
	},
	["music volume"] = {
		["description"] = "Displays music volume"
	},
	["music (1-100)"] = {
		["description"] = "Sets music volume to a specific value between 1 and 100 (1 and 100 inclusive)"
	},
	["ambience on"] = {
		["description"] = "Activates ambience"
	},
	["ambience off"] = {
		["description"] = "Deactivates ambience"
	},
	["ambience toggle"] = {
		["description"] = "Toggles ambience"
	},
	["ambience +"] = {
		["description"] = "Increases ambience volume by 5%"
	},
	["ambience -"] = {
		["description"] = "Decreases ambience volume by 5%"
	},
	["ambience volume"] = {
		["description"] = "Displays ambience volume"
	},
	["ambience (1-100)"] = {
		["description"] = "Sets ambience volume to a specific value between 1 and 100 (1 and 100 inclusive)"
	},
	["dialog on"] = {
		["description"] = "Activates dialog"
	},
	["dialog off"] = {
		["description"] = "Deactivates dialog"
	},
	["dialog toggle"] = {
		["description"] = "Toggles dialog"
	},
	["dialog +"] = {
		["description"] = "Increases dialog volume by 5%"
	},
	["dialog -"] = {
		["description"] = "Decreases dialog volume by 5%"
	},
	["dialog volume"] = {
		["description"] = "Displays dialog volume"
	},
	["dialog (1-100)"] = {
		["description"] = "Sets dialog volume to a specific value between 1 and 100 (1 and 100 inclusive)"
	},
	["sfx on"] = {
		["description"] = "Activates sfx"
	},
	["sfx off"] = {
		["description"] = "Deactivates sfx"
	},
	["sfx toggle"] = {
		["description"] = "Toggles sfx"
	},
	["sfx +"] = {
		["description"] = "Increases sfx volume by 5%"
	},
	["sfx -"] = {
		["description"] = "Decreases sfx volume by 5%"
	},
	["sfx volume"] = {
		["description"] = "Displays sfx volume"
	},
	["sfx (1-100)"] = {
		["description"] = "Sets sfx volume to a specific value between 1 and 100 (1 and 100 inclusive)"
	},
	["autoplay"] = {
		["description"] = "Toggles autoplay (random tracks played)"
	},
	["enableall"] = {
		["description"] = "Enables/Disables all sounds"
	},
	["master +"] = {
		["description"] = "Increases master volume by 5%"
	},
	["master -"] = {
		["description"] = "Decreases master volume by 5%"
	},
	["master volume"] = {
		["description"] = "Displays master volume"
	},
	["master (1-100)"] = {
		["description"] = "Sets master volume to a specific value between 1 and 100 (1 and 100 inclusive)"
	},
	["autoplay next"] = {
		["description"] = "Plays next song in autoplay"
	},
	["autoplay last"] = {
		["description"] = "Plays last autoplay song"
	},
	["song"] = {
		["description"] = "Displays current/last song"
	},
	["mini"] = {
		["description"] = "Shows/Hides Mini UI"
	},
	["autoplay off"] = {
		["description"] = "Turns autoplay off"
	},
	["autoplay favorite"] = {
		["description"] = "Toggles favorite autoplay (random favorite tracks played)"
	},
	["pause"] = {
		["description"] = "Pauses/Restarts the current track"
	},
	[shortcut .. " minimap"] = {
		["description"] = "Enables/Disables Minimap Icon"
	},
	[shortcut .. " help"] = {
		["description"] = "Displays all chat commands"
	}
}

length[1] = 0
length[2] = 0
for s in pairs(sounds) do
	length[1] = length[1] + 1
end
for s in pairs(commands) do
	length[2] = length[2] + 1
end

local playNext
local playTrack
local writeLines
local displayFrames
local showErrorFrame
local resume
local setupNewButton
local goBack
local scroll

SLASH_STARTSOUND1 = "/play"
SLASH_STOPSOUND1 = "/stop"
SLASH_EM1 = "/" .. shortcut
SLASH_MUSIC1 = "/music"
SLASH_AMBIENCE1 = "/ambience"
SLASH_DIALOG1 = "/dialog"
SLASH_SFX1 = "/sfx"
SLASH_AUTOPLAY1 = "/autoplay"
SLASH_ENABLEALL1 = "/enableall"
SLASH_SONG1 = "/song"
SLASH_MASTERVOLUME1 = "/master"
SLASH_MINI1 = "/mini"
SLASH_PAUSE1 = "/pause"

function executeMusic:toggleAutoplay()
	SlashCmdList.AUTOPLAY(nil,nil)
end
function executeMusic:toggleFavAutoplay()
	SlashCmdList.AUTOPLAY("favorite",nil)
end
function executeMusic:autoplayOff()
	SlashCmdList.AUTOPLAY("off",nil)
end
function executeMusic:hideTracks()
	f[1]:Hide()
end
function executeMusic:showTracks()
	f[1]:Show()
end
function executeMusic:hideCommands()
	f[2]:Hide()
end
function executeMusic:showCommands()
	f[2]:Show()
end
function executeMusic:hideMini()
	miniUi:Hide()
end
function executeMusic:showMini()
	miniUi:Show()
end
function executeMusic:errorMessage(message)
	showErrorFrame(message)
end
function executeMusic:createButton(pos, posX, posY, width, height, name, parentframe, font, rfc, rfcType, title)
	if parentframe == em_mainFrame1 or parentframe == em_mainFrame2 or em_miniUi then
		showErrorFrame("Not able to attach to a execute Music Frame")
		return nil
	end
	return setupNewButton(pos, posX, posY, width, height, name, parentframe, font, rfc, rfcType, title)
end
function executeMusic:nextSong()
	if paused or (not autoplay and not autoplayFavorite) then
		showErrorFrame("Paused or no autoplay started")
		return
	end
	playNext()
end
function executeMusic:lastSong()
	if paused or (not autoplay and not autoplayFavorite) then
		showErrorFrame("Paused or no autoplay started")
		return
	end
	goBack()
end
function executeMusic:togglePause()
	if notResumable then
		showErrorFrame("No music to pause/resume")
	end
	SlashCmdList.PAUSE(nil, nil)
end
function executeMusic:stopMusic()
	SlashCmdList.STOPSOUND(nil, nil, false, false)
end

local function round(x)
	x = x + 0.5 - (x + 0.5) % 1
	return x
end

local function hourToSec(x)
	return x * 3600
end

local function hourToMilSec(x)
	return x * 3600 * 1000
end

local function countEntries(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end

local function getLengthFrame()
	length[1] = 0
	if searched then
		length[1] = countEntries(matches)
	elseif showPlaylists then
		if playlistMenu or addTrackOngoing then
			length[1] = countEntries(playlists)
		else
			length[1] = countEntries(playlists[showPlaylist].tracks)
		end
	elseif showFavorites then
		length[1] = countEntries(favorites)
	elseif showBlacklist then
		length[1] = countEntries(blacklist)
	else
		length[1] = countEntries(sounds)
	end
end

local function getNumSounds()
	return #sounds
end

local function pairsByKeys (t)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
	end
	return iter
end

local function isDigit(s)
	return tonumber(s) ~= nil
end

local function removeDuplicates(t)
	local hash = {}
	local res = {}

	for _,v in ipairs(t) do
		if (not hash[v]) then
			res[#res+1] = v
			hash[v] = true
		end
	end
	return res
end

local function wait(delay)
    waitFrame = CreateFrame("Frame")
	waitUntil = GetTime() + delay
	waitFrame:SetScript("OnUpdate", function (...)
		if waitUntil <= GetTime() then
			waitUntil = math.huge
			if autoplay or autoplayFavorite then
				playNext()
			else
				SlashCmdList.STOPSOUND()
			end
		end
		return
	end)
end

local function queue(track, queueIt)
	if not queueIt then
		local found = false
		for i=1, autoplaySize, 1 do
			if autoplayList[i] == queuedSongs[1] then
				if i ~= autoplayPosition then
					autoplayList[i], autoplayList[autoplayPosition] = autoplayList[autoplayPosition], autoplayList[i]
					local j = autoplayPosition
					while j < (i - 1) do
						j = j + 1
						autoplayList[i], autoplayList[j] = autoplayList[j], autoplayList[i]
					end
					while j > (i + 1) do
						j = j - 1
						autoplayList[i], autoplayList[j] = autoplayList[j], autoplayList[i]
					end
				end
				local k = 0
				while k < queued do
					k = k + 1
					queuedSongs[k], queuedSongs[k+1] = queuedSongs[k+1], queuedSongs[k]
				end
				queuedSongs[queued] = nil
				queued = queued - 1
				if queued < 1 then
					queueUp = false
				end
				found = true
				break
			end
		end
		if not found then
			autoplaySize = autoplaySize + 1
			autoplayList[autoplaySize] = queuedSongs[1]
			local i = autoplayPosition
			autoplayList[i], autoplayList[autoplaySize] = autoplayList[autoplaySize], autoplayList[i]
			while i < (autoplaySize - 1) do
				i = i + 1
				autoplayList[i], autoplayList[autoplaySize] = autoplayList[autoplaySize], autoplayList[i]
			end
			local j = 0
			while j < queued do
				j = j + 1
				queuedSongs[j], queuedSongs[j+1] = queuedSongs[j+1], queuedSongs[j]
			end
			queuedSongs[queued] = nil
			queued = queued - 1
			if queued == 0 then
				queueUp = false
			end
		end
	else
		local found = false
		for position in pairs(queuedSongs) do
			if track == queuedSongs[position] then
				found = true
				break
			end
		end
		if not found then
			queued = queued + 1
			queuedSongs[queued] = track
			queueUp = true
		end
	end
	return
end

local function shuffle(list)
    for i = #list, 2, -1 do
        local j = math.random(1,i)
        list[i], list[j] = list[j], list[i]
    end
	return list
end

local function getDailyList()
	local tracks = {}
	local dailylist = {}
	local i = 0
	local duration = 0
	local minDuration = 5
	local found = false
	for track in pairs(log1000) do
		for sound in pairs(sounds) do
			if sounds[sound].sound == log1000[track] then
				found = false
				for song in pairs(tracks) do
					if sounds[tracks[song]].sound == log1000[track] then
						found = true
						break
					end
				end
				if not found then
					i = i + 1
					tracks[i] = sound
				end
				break
			end
		end
	end
	for favorite in pairs(favorites) do
		found = false
		for song in pairs(tracks) do
			if song == favorite then
				found = true
				break
			end
		end
		if not found then
			i = i + 1
			tracks[i] = favorite
		end
	end
	tracks = shuffle(tracks)
	local j = 0
	i = 0
	while duration < (hourToSec(minDuration) / 2) and tracks[j+1] ~= nil do
		j = j + 1
		found = false
		if blacklist[tracks[j]] == nil then
			i = i + 1
			dailylist[i] = tracks[j]
			duration = duration + sounds[tracks[j]].length
		end
	end
	tracks = {}
	j = 0
	for sound in pairs(sounds) do
		local h = 0
		num = heard[sound]
		if num == nil then
			num = 0
		end
		while h < num do
			h = h + 1
			j = j + 1
			tracks[j] = sound
		end
	end
	j = 0
	while duration < hourToSec(minDuration) and tracks[j+1] ~= nil do
		j = j + 1
		found = false
		if blacklist[tracks[j]] == nil then
			i = i + 1
			dailylist[i] = tracks[j]
			duration = duration + sounds[tracks[j]].length
		end
	end
	if duration < hourToSec(minDuration) then
		j = 0
		tracks = {}
		for sound in pairs(sounds) do
			if blacklist[sound] == nil then 
				found = false
				for track in pairs(dailylist) do
					if dailylist[track] == sound then
						found = true
						break
					end
				end
				if not found then
					j = j + 1
					tracks[j] = sound
				end
			end
		end
		tracks = shuffle(tracks)
		while duration < hourToSec(minDuration) and tracks[i+1] ~= nil do
			i = i + 1
			dailylist[i] = tracks[i]
			duration = duration + sounds[tracks[i]].length
		end
	end
	dailylist = shuffle(dailylist)
	dailyList.tracks = dailylist
	dailyList.Next = GetServerTime() + hourToSec(24)
	return true
end

local function getSuggestionList()
	local list = {}
	local i = 1
	local num = 0
	for track in pairs(sounds) do
		if blacklist[track] == nil then
			if heard[track] == nil or heard[track] <= 2 then
				list[i] = track
				i = i + 1
			end
		end
	end
	list = shuffle(list)
	j = 1
	duration = 0
	minDuration = hourToSec(2)
	suggestionList = {}
	numSounds = getNumSounds()
	while (duration < minDuration and j <= i) do
		suggestionList[j] = list[j]
		duration = duration + sounds[list[j]].length
		j = j + 1
	end
end

local function addTrackToAutoplay(track)
	local found = false
	local i = 0
	while i < autoplaySize do
		i = i + 1
		if autoplayList[i] == track then
			found = true
			break
		end
	end
	if not found then
		autoplaySize = autoplaySize + 1
		autoplayList[autoplaySize] = track
	end
	return
end

local function removeTrackFromAutoplay(track)
	local i = 0
	while i < autoplaySize do
		i = i + 1
		if autoplayList[i] == track then
			if autoplayPosition >= i then
				autoplayPosition = autoplayPosition - 1
				if autoplayPosition == i then
					playNext()
				end
			end
			while i <= autoplaySize do
				autoplayList[i], autoplayList[i+1] = autoplayList[i+1], autoplayList[i]
				i = i + 1
			end
			autoplayList[autoplaySize] = nil
			autoplaySize = autoplaySize - 1
			if autoplaySize == 0 then
				SlashCmdList.AUTOPLAY("off", nil)
			end
			return
		end
	end
	return
end

local function searchFor()
	matches = {}
	local i = 0
	if searchString == nil or searchString == "" then searched = false return end
	if not showFavorites and not showPlaylists and not addTrackOngoing then
		for sound in pairsByKeys(sounds) do
			if string.match(string.lower(string.gsub(sound, " ", "")), searchString) or string.match(string.lower(string.gsub(sounds[sound].description, " ", "")), searchString) then
				i = i + 1
				matches[i] = sound
			end
		end
	elseif (showPlaylists or addTrackOngoing) and not createPlaylistOngoing then
		if playlistMenu or addTrackOngoing then
			for pl in pairsByKeys(playlists) do
				if string.match(string.lower(string.gsub(pl, " ", "")), searchString) or string.match(string.lower(string.gsub(playlists[pl].description, " ", "")), searchString) then
					i = i + 1
					matches[i] = pl
				end
			end
		else
			if showPlaylist ~= "daily" and showPlaylist ~= "suggestions" then
				for track in pairs(playlists[showPlaylist].tracks) do
					if string.match(string.lower(string.gsub(playlists[showPlaylist].tracks, " ", "")), searchString) or string.match(string.lower(string.gsub(sounds[track].description, " ", "")), searchString) then
						i = i + 1
						matches[i] = track
					end
				end
			else
				for track in pairs(playlists[showPlaylist].tracks) do
					if string.match(string.lower(string.gsub(playlists[showPlaylist].tracks[track], " ", "")), searchString) or string.match(string.lower(string.gsub(sounds[playlists[showPlaylist].tracks[track]].description, " ", "")), searchString) then
						i = i + 1
						matches[i] = playlists[showPlaylist].tracks[track]
					end
				end
			end
		end
	elseif showFavorites then
		for favorite in pairsByKeys(favorites) do
			if string.match(string.lower(string.gsub(favorite, " ", "")), searchString) or string.match(string.lower(string.gsub(sounds[favorite].description, " ", "")), searchString) then
				i = i + 1
				matches[i] = favorite
			end
		end
	elseif createPlaylistOngoing then
		return
	end
	start[1] = 1
	ending[1] = i
	searched = true
	writeLines(false, 1)
	return
end

local function addFavorite(favorite)
	if favorite ~= nil and favorite ~= "" then
		if favorites[favorite] == nil then
			favorites[favorite] = favorite
			blacklist[favorite] = nil
			if autoplayFavorite then
				addTrackToAutoplay(track)
			end
		else
			favorites[favorite] = nil
			if autoplayFavorite then
				removeTrackFromAutoplay(track) 
			end
			if searched and showFavorites then
				searchFor()
			end
		end
		writeLines(false, 1)
		if frameStatus["miniui"] then
			update = true
		end
		return
	end
	return
end

local function addBlacklist (track)
	if track ~= nil and track ~= "" then
		if blacklist[track] == nil then
			blacklist[track] = track
			favorites[track] = nil
			if autoplayFavorite or (autoplay and currentAutoplayPlaylist == nil) then
				removeTrackFromAutoplay(track) 
			end
		else
			blacklist[track] = nil
			if (autoplay and currentAutoplayPlaylist == nil) then
				addTrackToAutoplay(track)
			end
			if searched and showBlacklist then
				searchFor()
			end
		end
		writeLines(false, 1)
		if frameStatus["miniui"] then
			update = true
		end
		return
	end
	return
end

local function addCustomTrack(name, description, filename, tracklength)
	if name ~= nil and name ~= "" and not string.match(name, "-") then
		if customs[name] == nil then
			if description ~= nil and description ~= "" then
				if filename ~= nil and filename ~= "" then
					local found = false
					for custom in pairs(customs) do
						if customs[custom].filename == filename then
							found = true
							break
						end
					end
					if not found then
						if tracklength ~= nil and tracklength ~= 0 then
							local found = false
							for track in pairs(sounds) do
								if track == name then
									found = true
									break
								end
							end
							if not found then
								local splittedName1, splittedName2, splittedName3 = strsplit(" ", name)
								if splittedName3 == nil then
									customs[name] = {
										["description"] = description,
										["filename"] = filename,
										["tracklength"] = tracklength,
										["format"] = "mp3"
									}
									sounds[name] = {
										["sound"] = filename,
										["description"] = description,
										["type"] = soundType.CUSTOM,
										["length"] = tracklength,
										["format"] = "mp3"
									}
									return true
								else
									showErrorFrame("The name should contain a maximum of 1 space")
									return false
								end
							else
								showErrorFrame("Sorry this name is already given to a existing track")
								return false
							end
						else
							showErrorFrame("Sorry without a length for this track I can't play it")
							return false
						end
					else
						showErrorFrame("A custom track on this filename is already registered")
						return false
					end
				else
					showErrorFrame("Please give me the filename otherwise I can't open it")
					return false
				end
			else
				showErrorFrame("Come on give it a try with a description otherwise you can't tell what you wanted to do here")
				return false
			end
		else 
			showErrorFrame("This custom track already exists, take another name")
			return false
		end
	elseif string.match(name, "-") then
		showErrorFrame('The name should not contain a "-"')
		return false
	else
		showErrorFrame("Be creative give the track a name")
		return false
	end
end

local function removeCustomTrack(name)
	if customs[name] ~= nil then
		if autoplay or autoplayFavorite then
			removeTrackFromAutoplay(name)
		end
		favorites[name] = nil
		for pl in playlists do
			pl.tracks[name] = nil
		end
		customs[name] = nil
		sounds[name] = nil
		return true
	else 
		showErrorFrame("This custom track doesn't exist")
		return false
	end
end

local function createPlaylist(name, description)
	if name ~= nil and name ~= "" and not string.match(name, "-") then
		if playlists[name] == nil then
			if description ~= nil and description ~= "" then
				local splittedName1, splittedName2, splittedName3 = strsplit(" ", name)
				if splittedName3 == nil then
					playlists[name] = {
						["description"] = description,
						["tracks"] = {}
					}
					writeLines(false, 1)
					return true
				else
					showErrorFrame("The name should contain a maximum of 1 space")
				end
			else
				showErrorFrame("Come on give it a try with a description otherwise you can't tell what you wanted to do here")
				return false
			end
		else 
			showErrorFrame("This playlist already exists, take another name")
			return false
		end
	elseif string.match(name, "-") then
		showErrorFrame('The playlist name should not contain a "-"')
		return false
	else
		showErrorFrame("Be creative give the playlist a name")
		return false
	end
end

local function deletePlaylist(playlistName)
	if playlists[playlistName] ~= nil then
		playlists[playlistName] = nil
		if currentAutoplayPlaylist == playlistName then
			SlashCmdList.AUTOPLAY("off", nil)
		end
		writeLines(false, 1)
		return
	else
		showErrorFrame("A playlist with this name doesn't exist")
		return
	end
end

local function addTrack(playlistName, track)
	if playlistName ~= nil and playlistName ~= "" then
		if playlists[playlistName] ~= nil then
			if track ~= nil and sounds[track] ~= nil then
				if playlists[playlistName].tracks[track] == nil then
					playlists[playlistName].tracks[track] = track
					addTrackOngoing = false
					if currentAutoplayPlaylist == playlistName then
						addTrackToAutoplay(track)
					end
					searchFor()
					writeLines(false, 1)
					return
				else
					showErrorFrame("This track already exists in this playlist")
					return
				end
			else
				showErrorFrame("This track doesn't exist")
				return
			end
		else
			showErrorFrame("The playlistname doesn't exist")
		end
	else
		showErrorFrame("The playlistname is empty")
		return
	end
end

local function removeTrack(playlistName, track)
	if playlists[playlistName] ~= nil then
		if playlists[playlistName].tracks[track] ~= nil then
			playlists[playlistName].tracks[track] = nil
			if currentAutoplayPlaylist == showPlaylist then
				removeTrackFromAutoplay()
			end
			searchFor()
			writeLines(false, 1)
			return
		else
			showErrorFrame("A track with this name doesn't exist in " .. playlistName)
			return
		end
	else
		showErrorFrame("A track with this name doesn't exist")
		return
	end
end

local function showSearchFrame()
	showFavoriteFrame = false
	local j = 0
	if createPlaylistOngoing or addCustomTrackOngoing then return end
	if (not showPlaylists or not playlistMenu) and not addTrackOngoing then	
		buttonAddPl:SetText(L["Add Custom"])
		buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 320, -10)
		buttonAddPl:Show()
		while j < number[1] do
			j = j + 1
			if matches[j + start[1] - 1] ~= nil then
				local description = sounds[matches[j + start[1] - 1]].description
				local text = tostring(matches[j + start[1] - 1]) .. " - " .. tostring(description)
				strings[j]:SetText(text)
				buttons[j]:SetText(L["Play"])
				buttons[j]:Show()
				if showPlaylists or showBlacklist or showFavorites then
					buttonsF[j]:SetText(L["Remove"])
					buttonsB[j]:SetText(L["Add to"])
					if sounds[matches[j + start[1] - 1]].type == soundType.CUSTOM then
						buttonsAT[j]:SetText(L["Delete"])
						buttonsAT[j]:Show()
					else
						buttonsAT[j]:Hide()
					end
					buttonsD[j]:Hide()
				else
					if blacklist[matches[j + start[1] - 1]] ~= nil then
						buttonsB[j]:SetText(L["Remove"])
					else	
						buttonsB[j]:SetText(L["Blacklist"])
					end
					if favorites[matches[j + start[1] - 1]] ~= nil then
						buttonsF[j]:SetText(L["Remove"])
					else
						buttonsF[j]:SetText(L["Favorite"])
					end
					if sounds[matches[j + start[1] - 1]].type == soundType.CUSTOM then
						buttonsD[j]:Show()
					else
						buttonsD[j]:Hide()
					end
					buttonsAT[j]:SetText(L["Add to"])
					buttonsAT[j]:Show()
				end
				buttonsB[j]:Show()
				buttonsF[j]:Show()
			else
				strings[j]:SetText("")
				buttons[j]:Hide()
				buttonsF[j]:Hide()
				buttonsB[j]:Hide()
				buttonsAT[j]:Hide()
				buttonsD[j]:Hide()
			end
		end
		return
	else
		buttonAddPl:Show()
		while j < number[1] do
			j = j + 1
			if matches[j + start[1] - 1] ~= nil then
				local description = playlists[matches[j + start[1] - 1]].description
				local text = tostring(matches[j + start[1] - 1]) .. " - " .. tostring(description)
				strings[j]:SetText(text)
				buttons[j]:SetText(L["Open"])
				buttons[j]:Show()
				buttonsF[j]:Show()
				if not addTrackOngoing then
					buttonsB[j]:SetText(L["Autoplay"])
					buttonsB[j]:Show()
				else
					buttonsB[j]:Hide()
				end
				buttonsAT[j]:Hide()
				buttonsD[j]:Hide()
			else
				strings[j]:SetText("")
				buttons[j]:Hide()
				buttonsF[j]:Hide()
				buttonsB[j]:Hide()
				buttonsAT[j]:Hide()
				buttonsD[j]:Hide()
			end
		end
		return
	end
end

local function showPlaylistFrame()
	if playlistMenu and not createPlaylistOngoing and not addTrackOngoing then
		if dailyList.Next == nil or dailyList.Next <= GetServerTime() then
			getDailyList()
			playlists["daily"] = nil
			playlists["daily"] = {
				["description"] = "Your daily playlist",
				["tracks"] = dailyList.tracks;
			}
			getSuggestionList()
			playlists["suggestions"] = nil
			playlists["suggestions"] = {
				["description"] = "Your daily suggestion list of never or close to never heard songs",
				["tracks"] = suggestionList;
			}
		end
		buttonAddPl:SetText(L["Add Playlist"])
		buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 320, -10)
		buttonAddPl:Show()
		local i = 0
		local j = 0
		for pl in pairsByKeys(playlists) do
			j = j + 1
			if j > ending[1] then
				break
			end
			if j >= start[1] then
				i = i + 1
				local description = playlists[pl].description
				local text = tostring(pl .. " - " .. tostring(description))
				strings[i]:SetText(text)
				buttons[i]:SetText(L["Open"])
				buttons[i]:Show()
				buttonsF[i]:SetText(L["Delete"])
				buttonsF[i]:Show()
				buttonsB[i]:SetText(L["Autoplay"])
				buttonsB[i]:Show()
				buttonsAT[i]:Hide()
				buttonsD[i]:Hide()
			end
		end
		while i < number[1] do
			i = i + 1
			strings[i]:SetText("")
			buttons[i]:Hide()
			buttonsF[i]:Hide()
			buttonsB[i]:Hide()
			buttonsAT[i]:Hide()
			buttonsD[i]:Hide()
		end
		return
	elseif not createPlaylistOngoing and not addTrackOngoing then
		buttonAddPl:SetText(L["Back"])
		buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 295, -10)
		buttonAddPl:Show()
		local i = 0
		local j = 0
		local found
		local foundO = true
		for track in pairsByKeys(playlists[showPlaylist].tracks) do
			j = j + 1
			if j > ending[1] then
				break
			end
			if j >= start[1] then
				i = i + 1
				if sounds[playlists[showPlaylist].tracks[track]] == nil then
					playlists[showPlaylist].tracks[track] = nil
					writeLines(false,1)
					found = false
					foundO = false
				else
					found = true
				end
				if found then
					local description = sounds[playlists[showPlaylist].tracks[track]].description
					local text = tostring(playlists[showPlaylist].tracks[track] .. " - " .. tostring(description))
					strings[i]:SetText(text)
					buttons[i]:SetText(L["Play"])
					buttons[i]:Show()
					buttonsF[i]:SetText(L["Remove"])
					buttonsF[i]:Show()
					buttonsB[i]:SetText(L["Add To"])
					buttonsB[i]:Show()
					if sounds[playlists[showPlaylist].tracks[track]].type == soundType.CUSTOM then
						buttonsAT[i]:SetText(L["Delete"])
						buttonsAT[i]:Show()
					else
						buttonsAT[i]:Hide()
					end
					buttonsD[i]:Hide()
				end
			end
		end
		if not foundO then
			showErrorFrame(L["Sorry for this but I had to remove some tracks, due to namechange or removal, from your list"])
		end
		while i < number[1] do
			i = i + 1
			strings[i]:SetText("")
			buttons[i]:Hide()
			buttonsF[i]:Hide()
			buttonsB[i]:Hide()
			buttonsAT[i]:Hide()
			buttonsD[i]:Hide()
		end
		return
	elseif not addTrackOngoing then
		local i = 0
		while i < number[1] do
			i = i + 1
			strings[i]:SetText("")
			editBox[i]:Hide()
			buttons[i]:Hide()
			buttonsF[i]:Hide()
			buttonsB[i]:Hide()
			buttonsAT[i]:Hide()
			buttonsD[i]:Hide()
		end	
		buttonAddPl:SetText(L["Back"])
		buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 295, -10)
		buttonAddPl:Show()
		strings[1]:SetText(L["Name:"])
		strings[1]:Show()
		editBox[1]:SetPoint("TOPLEFT", 110, ((size * -1) - size - titlesizeextra))
		editBox[1]:Show()
		strings[2]:SetText(L["Description:"])
		strings[2]:Show()
		editBox[2]:SetPoint("TOPLEFT", 110, ((size * -2) - size - titlesizeextra))
		editBox[2]:Show()
		buttonSubmit:Show()
		return
	else
		buttonAddPl:SetText(L["Back"])
		buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 295, -10)
		buttonAddPl:Show()
		local i = 0
		local j = 0
		for pl in pairsByKeys(playlists) do
			j = j + 1
			if j > ending[1] then
				break
			end
			if j >= start[1] then
				i = i + 1
				local description = playlists[pl].description
				local text = tostring(pl .. " - " .. tostring(description))
				strings[i]:SetText(text)
				buttons[i]:SetText(L["Add to"])
				buttons[i]:Show()
				buttonsF[i]:Hide()
				buttonsB[i]:Hide()
				buttonsAT[i]:Hide()
				buttonsD[i]:Hide()
			end
		end
		while i < number[1] do
			i = i + 1
			j = j + 1
			strings[i]:SetText("")
			buttons[i]:Hide()
			buttonsF[i]:Hide()
			buttonsB[i]:Hide()
			buttonsAT[i]:Hide()
			buttonsD[i]:Hide()
		end
		return
	end
end

local function showFavoriteFrame()
	buttonAddPl:Hide()
	local i = 0
	local j = 0
	local foundO = true
	local found
	for fa in pairsByKeys(favorites) do
		j = j + 1
		if j > ending[1] then
			break
		end
		if j >= start[1] then
			i = i + 1
			if sounds[fa] == nil then
				favorites[fa] = nil
				writeLines(false,1)
				found = false
				foundO = false
			else
				found = true
			end
			if found then
				local description = sounds[fa].description
				local text = tostring(fa .. " - " .. tostring(description))
				strings[i]:SetText(text)
				buttons[i]:SetText(L["Play"])
				buttons[i]:Show()
				buttonsF[i]:SetText(L["Remove"])
				buttonsF[i]:Show()
				buttonsB[i]:SetText(L["Add To"])
				buttonsB[i]:Show()
				if sounds[fa].type == soundType.CUSTOM then
					buttonsAT[i]:SetText(L["Delete"])
					buttonsAT[i]:Show()
				else
					buttonsAT[i]:Hide()
				end
				buttonsD[i]:Hide()
			end
		end
	end
	if not foundO then
		showErrorFrame(L["Sorry for this but I had to remove some tracks, due to namechange or removal, from your list"])
	end
	while i < number[1] do
		i = i + 1
		strings[i]:SetText("")
		buttons[i]:Hide()
		buttonsF[i]:Hide()
		buttonsB[i]:Hide()
		buttonsAT[i]:Hide()
		buttonsD[i]:Hide()
	end
	return
end

local function showBlacklistFrame()
	buttonAddPl:Hide()
	local i = 0
	local j = 0
	local foundO = true
	local found
	for bl in pairsByKeys(blacklist) do
		j = j + 1
		if j > ending[1] then
			break
		end
		if j >= start[1] then
			i = i + 1
			if sounds[bl] == nil then
				blacklist[bl] = nil
				writeLines(false,1)
				found = false
				foundO = false
			else
				found = true
			end
			if found then
				local description = sounds[bl].description
				local text = tostring(bl .. " - " .. tostring(description))
				strings[i]:SetText(text)
				buttons[i]:SetText(L["Play"])
				buttons[i]:Show()
				buttonsF[i]:SetText(L["Remove"])
				buttonsF[i]:Show()
				buttonsB[i]:SetText(L["Add To"])
				buttonsB[i]:Show()
				if sounds[bl].type == soundType.CUSTOM then
					buttonsAT[i]:SetText(L["Delete"])
					buttonsAT[i]:Show()
				else
					buttonsAT[i]:Hide()
				end
				buttonsD[i]:Hide()
			end
		end
	end
	if not foundO then
		showErrorFrame(L["Sorry for this but I had to remove some tracks, due to namechange or removal, from your list"])
	end
	while i < number[1] do
		i = i + 1
		strings[i]:SetText("")
		buttons[i]:Hide()
		buttonsF[i]:Hide()
		buttonsB[i]:Hide()
		buttonsAT[i]:Hide()
		buttonsD[i]:Hide()
	end
	return
end

setupNewButton = function(pos, posX, posY, width, height, name, parentframe, font, rfc, rfcType, title)
	local button = CreateFrame("Button", title, parentframe)
	button:SetPoint(pos, posX, posY)
	button:SetWidth(width)
	button:SetHeight(height)

	button:SetText(L[name])
	button:SetNormalFontObject(font)

	if rfc then
		button:RegisterForClicks(rfcType)
	end
	return button
end

local function setupBase(frame)
	if frame == 1 then
		local button = setupNewButton("TOPRIGHT", -10, -10, 30, 30, "Close", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)
		button:SetScript("OnClick", function (self, button, down)
			f[1]:Hide()
		end)

		button = setupNewButton("TOPLEFT", 140, -10, 30, 30, "Search", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)
		button:SetScript("OnClick", function (self, button, down)
			searchString = searchBox:GetText()
			searchString = string.lower(string.gsub(searchString, " ", ""))
			searchFor()
		end)
		
		local offset
		if lang == "deDE" then
			offset = 190
		else
			offset = 180
		end
		button = setupNewButton("TOPLEFT", offset, -10, 30, 30, "Clear", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		button:SetScript("OnClick", function (self, button, down)
			searchString = nil
			searched = false
			start[1] = 1
			scroll(0, 1)
			writeLines(false, 1)
			searchBox:SetText("")
		end)

		searchBox = CreateFrame("EditBox", nil, em_mainFrame1, "InputBoxTemplate")
		searchBox:SetFrameStrata("HIGH")
		searchBox:SetHeight(20)
		searchBox:SetWidth(120)
		searchBox:SetAutoFocus(false)
		searchBox:SetPoint("TOPLEFT", 10, -10)

		button = setupNewButton("TOPLEFT", f[frame]:GetWidth() - 100, -10, 30, 30, "Favorites", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		button:SetScript("OnClick", function (self, button, down)
			showFavorites = not showFavorites
			showBlacklist = false
			showPlaylists = false
			createPlaylistOngoing = false
			addTrackOngoing = false
			addCustomTrackOngoing = false
			editBox[1]:Hide()
			editBox[2]:Hide()
			editBox[3]:Hide()		
			editBox[4]:Hide()
			start[1] = 1
			buttonSubmit:Hide()
			buttonSubmitCustom:Hide()
			searched = false
			searchString = nil
			start[1] = 1
			scroll(0, 1)
			writeLines(false, 1)
		end)

		button = setupNewButton("TOPLEFT", f[frame]:GetWidth() - 170, -10, 30, 30, "Blacklist", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		button:SetScript("OnClick", function (self, button, down)
			showBlacklist = not showBlacklist
			showFavorites = false
			showPlaylists = false
			createPlaylistOngoing = false
			addTrackOngoing = false
			addCustomTrackOngoing = false
			start[1] = 1
			editBox[1]:Hide()
			editBox[2]:Hide()
			editBox[3]:Hide()		
			editBox[4]:Hide()
			buttonSubmit:Hide()
			buttonSubmitCustom:Hide()
			searched = false
			searchString = nil
			start[1] = 1
			scroll(0, 1)
			writeLines(false, 1)
		end)

		button = setupNewButton("TOPLEFT", f[frame]:GetWidth() - 240, -10, 30, 30, "Playlists", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		button:SetScript("OnClick", function (self, button, down)
			showPlaylists = not showPlaylists
			playlistMenu = true
			createPlaylistOngoing = false
			addTrackOngoing = false
			addCustomTrackOngoing = false
			showFavorite = false
			showBlacklist = false
			editBox[1]:Hide()
			editBox[2]:Hide()
			editBox[3]:Hide()		
			editBox[4]:Hide()	
			buttonSubmit:Hide()
			buttonSubmitCustom:Hide()
			start[1] = 1
			searched = false
			searchString = nil
			start[1] = 1
			scroll(0, 1)
			writeLines(false, 1)
		end)

		buttonAddPl = setupNewButton("TOPLEFT", f[frame]:GetWidth() - 320, -10, 30, 30, "Add Playlist", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		buttonAddPl:SetScript("OnClick", function (self, button, down)
			start[1] = 1
			start[1] = 1
			scroll(0, 1)
			if showPlaylists and playlistMenu and not addTrackOngoing and not createPlaylistOngoing then
				createPlaylistOngoing = true
				searched = false
				writeLines(false, 1)
			elseif addTrackOngoing then
				addTrackOngoing = false
				searchFor()
				writeLines(false, 1)
			elseif createPlaylistOngoing then
				editBox[1]:Hide()
				editBox[2]:Hide()		
				buttonSubmit:Hide()
				createPlaylistOngoing = false
				searchFor()
				writeLines(false, 1)
			elseif addCustomTrackOngoing then
				editBox[1]:Hide()
				editBox[2]:Hide()
				editBox[3]:Hide()		
				editBox[4]:Hide()
				buttonSubmitCustom:Hide()
				addCustomTrackOngoing = false
				searchFor()
				writeLines(false, 1)
			elseif showPlaylists and not playlistMenu then
				playlistMenu = true
				searched = false
				writeLines(false, 1)
			else
				addCustomTrackOngoing = true
				searched = false
				writeLines(false, 1)
			end
		end)

		buttonSubmit = setupNewButton("TOP", 0, ((size * 3 * -1) - size - titlesizeextra), 50, 50, "Create", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		buttonSubmit:SetScript("OnClick", function (self, button, down)
			local name = editBox[1]:GetText()
			local description = editBox[2]:GetText()
			if createPlaylist(name, description) then
				createPlaylistOngoing = false
				editBox[1]:Hide()
				editBox[2]:Hide()		
				buttonSubmit:Hide()
				searchFor()
				writeLines(false, 1)
			end
		end)		
		buttonSubmit:Hide()

		buttonSubmitCustom = setupNewButton("TOP", 0, ((size * 5 * -1) - size - titlesizeextra), 50, 50, "Add", em_mainFrame1, "GameFontNormal", true, "AnyUp", nil)	
		buttonSubmitCustom:SetScript("OnClick", function (self, button, down)
			local name = editBox[1]:GetText()
			local description = editBox[2]:GetText()
			local filename = editBox[3]:GetText()
			local lengthTrack = editBox[4]:GetText()
			if addCustomTrack(name, description, filename, lengthTrack) then
				addCustomTrackOngoing = false
				editBox[1]:Hide()
				editBox[2]:Hide()
				editBox[3]:Hide()		
				editBox[4]:Hide()
				buttonSubmitCustom:Hide()
				searchFor()
				writeLines(false, 1)
			end
		end)		
		buttonSubmit:Hide()
		return
	elseif frame == 2 then
		local button = setupNewButton("TOPRIGHT", -10, -10, 30, 30, "Close", em_mainFrame2, "GameFontNormal", true, "AnyUp", nil)	
		button:SetScript("OnClick", function (self, button, down)
			f[2]:Hide()
		end)
		return
	end
end

local function setupBase2(frame, position, s)
	if frame == 1 then
		strings[position] = f[frame]:CreateFontString(s)
		strings[position]:SetFont("Fonts\\FRIZQT__.TTF", size - 1, "OUTLINE, MONOCHROME")
		strings[position]:SetPoint("TOPLEFT", 10, ((size * position * -1) - size - titlesizeextra))

		editBox[position] = CreateFrame("EditBox", nil, em_mainFrame1, "InputBoxTemplate")
		editBox[position]:SetFrameStrata("HIGH")
		editBox[position]:SetHeight(size)
		editBox[position]:SetWidth(200)
		editBox[position]:SetAutoFocus(false)
		editBox[position]:SetPoint("TOPLEFT", 110, ((size * position * -1) - size - titlesizeextra))
		editBox[position]:Hide()

		local xPos = f[frame]:GetWidth() - 40
		local yPos = (size * position * -1) - size - titlesizeextra
		local height = size + 5
		buttons[position] = setupNewButton("TOPLEFT", xPos, yPos, 30, height, "Play", em_mainFrame1, "GameFontNormal", true, "AnyUp", position)
		buttons[position]:SetScript("OnClick", function (self, button, down)
			if (not showPlaylists or not playlistMenu) and not addTrackOngoing then
				local text = strings[tonumber(self:GetName())]:GetText()
				local trackId = strsplit("-", text)
				local trackId, trackId2 = strsplit(" ", trackId)
				if trackId2 ~= "" then
					trackId = trackId .. " " .. trackId2
				end
				local track = sounds[trackId]
				if track ~= nil then
					if not autoplay and not autoplayFavorite then
						playTrack(track)
					else
						queue(trackId, true)
					end
				end
				return
			elseif not addTrackOngoing then
				playlistMenu = false
				searched = false
				searchString = nil
				local playlist = strsplit("-", strings[tonumber(self:GetName())]:GetText())
				local playlist, playlist2 = strsplit(" ", playlist)
				if playlist2 ~= "" then
					playlist = playlist .. " " .. playlist2
				end
				showPlaylist = playlist
				start[1] = 1
				scroll(0, 1)
				writeLines(false, 1)
				return
			else
				local playlist = strsplit("-", strings[tonumber(self:GetName())]:GetText())
				local playlist, playlist2 = strsplit(" ", playlist)
				if playlist2 ~= "" then
					playlist = playlist .. " " .. playlist2
				end
				addTrack(playlist, trackToAdd)
				return
			end
		end)
		buttons[position]:SetScript('OnEnter', function(self)
			strings[tonumber(self:GetName())]:SetTextColor(0, 1, 1)
		end)
		buttons[position]:SetScript('OnLeave', function(self) 
			strings[tonumber(self:GetName())]:SetTextColor(1, 1, 1)
		end)

		xPos = f[frame]:GetWidth() - 100
		buttonsF[position] = setupNewButton("TOPLEFT", xPos, yPos, 30, height, "Favorite", em_mainFrame1, "GameFontNormal", true, "AnyUp", position)
		buttonsF[position]:SetScript("OnClick", function (self, button, down)
			if not showPlaylists then
				if not showBlacklist then
					local fa1, fa2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
					local favorite
					if fa2 ~= "-" then
						favorite = fa1 .. " " .. fa2
					else
						favorite = fa1
					end
					addFavorite(favorite)
				else
					local bl1, bl2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
					local blacklisted
					if bl2 ~= "-" then
						blacklisted = bl1 .. " " .. bl2
					else
						blacklisted = bl1
					end
					addBlacklist(blacklisted)
				end
			elseif playlistMenu then
				local playlist = strsplit("-", strings[tonumber(self:GetName())]:GetText())
				local playlist, playlist2 = strsplit(" ", playlist)
				if playlist2 ~= "" then
					playlist = playlist .. " " .. playlist2
				end
				deletePlaylist(playlist)
				if searched then
					searchFor()
				end
				writeLines(false, 1)
			else
				local track1, track2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
				local track
				if track2 ~= "-" then
					track = track1 .. " " .. track2
				else
					track = track1
				end
				removeTrack(showPlaylist, track)
				if searched then
					searchFor()
				end
				writeLines(false, 1)
			end
		end)
		buttonsF[position]:SetScript('OnEnter', function(self)
			strings[tonumber(self:GetName())]:SetTextColor(0, 1, 1)
		end)
		buttonsF[position]:SetScript('OnLeave', function(self) 
			strings[tonumber(self:GetName())]:SetTextColor(1, 1, 1)
		end)

		xPos = f[frame]:GetWidth() - 170
		buttonsB[position] = setupNewButton("TOPLEFT", xPos, yPos, 30, height, "Blacklist", em_mainFrame1, "GameFontNormal", true, "AnyUp", position)
		buttonsB[position]:SetScript("OnClick", function (self, button, down)
			if not showPlaylists and not showFavorites and not showBlacklist then
				local bl1, bl2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
				local blacklisted
				if bl2 ~= "-" then
					blacklisted = bl1 .. " " .. bl2
				else
					blacklisted = bl1
				end
				addBlacklist(blacklisted)
			elseif (showPlaylists and not playlistMenu) or showFavorites or showBlacklist then
				searched = false
				local track1, track2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
				local track
				if track2 ~= "-" then
					track = track1 .. " " .. track2
				else
					track = track1
				end
				trackToAdd = track
				addTrackOngoing = true
				start[1] = 1
				scroll(0, 1)
				writeLines(false, 1)
			else
				local playlist = strsplit("-", strings[tonumber(self:GetName())]:GetText())
				local playlist, playlist2 = strsplit(" ", playlist)
				if playlist2 ~= "" then
					playlist = playlist .. " " .. playlist2
				end
				if playlist ~= "daily" and playlist ~= "suggestions" then
					local found = false
					for track in pairs(playlists[playlist].tracks) do
						found = true
						break
					end
					if not found then
						showErrorFrame(L["No tracks added"])
						return
					end
					autoplay = true
					local i = 0
					local found
					local foundO = true
					local autoplayFavorite = false;
					SlashCmdList.AUTOPLAY("SetupNew", nil)
					for track in pairs(playlists[playlist].tracks) do
						if sounds[track] == nil then
							playlists[playlist].tracks[track] = nil
							writeLines(false,1)
							found = false
							foundO = false
						else
							found = true
						end
						if found then
							i = i + 1
							autoplayList[i] = track
						end
					end
					if i == 0 then
						showErrorFrame(L["No tracks to play available"])
						return
					end
					if not foundO then
						showErrorFrame("Sorry for this but I had to remove some tracks, due to namechange or removal, from your list")
					end
					autoplaySize = i
					autoplayPosition = 1
					currentAutoplayPlaylist = playlist
					resume()
					autoplayList = shuffle(autoplayList)
					playNext()
					print(L['Playlist "' .. playlist .. '" Autoplay on'])
				elseif playlist == "daily" then
					local found = false
					for track in pairs(playlists[playlist].tracks) do
						found = true
						break
					end
					if not found then
						showErrorFrame(L["No more tracks available today"])
						return
					end
					autoplay = true
					local i = 1
					local foundO = true
					local autoplayFavorite = false;
					SlashCmdList.AUTOPLAY("SetupNew", nil)
					while dailyList.tracks[i] ~= nil do
						if sounds[dailyList.tracks[i]] == nil then
							playlists[playlist].tracks[i] = nil
							local j = i
							while dailyList.tracks[j] ~= nil do
								dailyList.tracks[j], dailyList.tracks[j+1] = dailyList.tracks[j+1], dailyList.tracks[j]
								j = j + 1
							end
							writeLines(false,1)
							foundO = false
						else
							autoplayList[i] = dailyList.tracks[i]
							i = i + 1
						end
					end
					i = i - 1
					if not foundO then
						showErrorFrame("Sorry for this but I had to remove some tracks, due to namechange or removal, from your list")
					end
					if i == 0 then
						showErrorFrame(L["No tracks to play available"])
						return
					end
					autoplaySize = i
					autoplayPosition = 1
					currentAutoplayPlaylist = playlist
					resume()
					playNext()
					print(L['Your daily autoplay starts now'])
				else
					local found = false
					for track in pairs(playlists[playlist].tracks) do
						found = true
						break
					end
					if not found then
						showErrorFrame(L["No more tracks available today"])
						return
					end
					autoplay = true
					local i = 1
					local foundO = true
					local autoplayFavorite = false;
					SlashCmdList.AUTOPLAY("SetupNew", nil)
					while suggestionList[i] ~= nil do
						if sounds[suggestionList[i]] == nil then
							playlists[playlist].tracks[i] = nil
							local j = i
							while suggestionList[j] ~= nil do
								suggestionList[j], suggestionList[j+1] = suggestionList[j+1], suggestionList[j]
								j = j + 1
							end
							writeLines(false,1)
							foundO = false
						else
							autoplayList[i] = suggestionList[i]
							i = i + 1
						end
					end
					i = i - 1
					if not foundO then
						showErrorFrame("Sorry for this but I had to remove some tracks, due to namechange or removal, from your list")
					end
					if i == 0 then
						showErrorFrame(L["No tracks to play available"])
						return
					end
					autoplaySize = i
					autoplayPosition = 1
					currentAutoplayPlaylist = playlist
					resume()
					playNext()
					print(L['Your daily suggestion list starts now'])
				end
			end
		end)
		buttonsB[position]:SetScript('OnEnter', function(self)
			strings[tonumber(self:GetName())]:SetTextColor(0, 1, 1)
		end)
		buttonsB[position]:SetScript('OnLeave', function(self) 
			strings[tonumber(self:GetName())]:SetTextColor(1, 1, 1)
		end)

		xPos = f[frame]:GetWidth() - 240
		buttonsAT[position] = setupNewButton("TOPLEFT", xPos, yPos, 30, height, "Add to", em_mainFrame1, "GameFontNormal", true, "AnyUp", position)
		buttonsAT[position]:SetScript("OnClick", function (self, button, down)
			if not showPlaylists and not showFavorites and not showBlacklist then
				searched = false
				local track1, track2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
				local track
				if track2 ~= "-" then
					track = track1 .. " " .. track2
				else
					track = track1
				end
				trackToAdd = track
				addTrackOngoing = true
				start[1] = 1
				scroll(0, 1)
				writeLines(false, 1)
			else
				local track1, track2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
				local track
				if track2 ~= "-" then
					track = track1 .. " " .. track2
				else
					track = track1
				end
				customs[track] = nil
				sounds[track] = nil
				if autoplayFavorite or autoplay then
					for position in pairs(autoplayList) do
						if track == autoplayList[position] then
							autoplayList[position] = nil
							autoplayList[position], autoplayList[autoplaySize] = autoplayList[autoplaySize], autoplayList[position]
							autoplaySize = autoplaySize - 1
							if autoplaySize == 0 then
								SlashCmdList.AUTOPLAY("off", nil)
							end
						end
					end
				end
				favorites[track] = nil
				for playlist in pairs(playlists) do
					playlists[playlist].tracks[track] = nil
				end
				if searched then
					searchFor()
				end
				writeLines(false, 1)
			end
		end)
		buttonsAT[position]:SetScript('OnEnter', function(self)
			strings[tonumber(self:GetName())]:SetTextColor(0, 1, 1)
		end)
		buttonsAT[position]:SetScript('OnLeave', function(self) 
			strings[tonumber(self:GetName())]:SetTextColor(1, 1, 1)
		end)

		xPos = f[frame]:GetWidth() - 310
		buttonsD[position] = setupNewButton("TOPLEFT", xPos, yPos, 30, height, "Delete", em_mainFrame1, "GameFontNormal", true, "AnyUp", position)
		buttonsD[position]:SetScript("OnClick", function (self, button, down)
			local track1, track2 = strsplit(" ", strings[tonumber(self:GetName())]:GetText())
			local track
			if track2 ~= "-" then
				track = track1 .. " " .. track2
			else
				track = track1
			end
			customs[track] = nil
			sounds[track] = nil
			if autoplayFavorite or autoplay then
				for position in pairs(autoplayList) do
					if track == autoplayList[position] then
						autoplayList[position] = nil
						autoplayList[position], autoplayList[autoplaySize] = autoplayList[autoplaySize], autoplayList[position]
						autoplaySize = autoplaySize - 1
						if autoplaySize == 0 then
							SlashCmdList.AUTOPLAY("off", nil)
						end
					end
				end
			end
			favorites[track] = nil
			for playlist in pairs(playlists) do
				playlists[playlist].tracks[track] = nil
			end
			if searched then
				searchFor()
			end
			writeLines(false, 1)
		end)
		buttonsD[position]:SetScript('OnEnter', function(self)
			strings[tonumber(self:GetName())]:SetTextColor(0, 1, 1)
		end)
		buttonsD[position]:SetScript('OnLeave', function(self) 
			strings[tonumber(self:GetName())]:SetTextColor(1, 1, 1)
		end)
	elseif frame == 2 then
		stringsC[position] = f[frame]:CreateFontString(s)
		stringsC[position]:SetFont("Fonts\\FRIZQT__.TTF", size - 1, "OUTLINE, MONOCHROME")
		stringsC[position]:SetPoint("TOPLEFT", 10, ((size * position * -1) - size - titlesizeextra))
	end
end

local function setupButtons(width)
	local offset
	if lang == "deDE" then
		offset = -10
	else
		offset = -5
	end
	local button = setupNewButton("TOPRIGHT", offset, 0, 30, 20, "Close", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		miniUi:Hide()
	end)

	buttonAP = setupNewButton("BOTTOM", 0, 0, 30, 20, "Autoplay", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonAP:SetScript("OnClick", function (self, button, down)
		if not autoplay and not autoplayFavorite then
			buttonAP:Hide()
			buttonAPF:Show()
			buttonAPN:Show()
			buttonLists:Hide()
			buttonCancel:Show()
		else
			SlashCmdList.AUTOPLAY("off")
		end
	end)

	buttonAPN = setupNewButton("BOTTOM", 25, 0, 30, 20, "Normal", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonAPN:SetScript("OnClick", function (self, button, down)
		buttonAPF:Hide()
		buttonAPN:Hide()
		buttonAP:Show()
		buttonCancel:Hide()
		buttonLists:Show()
		SlashCmdList.AUTOPLAY()
	end)
	buttonAPN:Hide()

	buttonAPF = setupNewButton("BOTTOM", -25, 0, 30, 20, "Favorite", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonAPF:SetScript("OnClick", function (self, button, down)
		buttonAPF:Hide()
		buttonAPN:Hide()
		buttonAP:Show()
		buttonCancel:Hide()
		buttonLists:Show()
		SlashCmdList.AUTOPLAY("favorite")
	end)
	buttonAPF:Hide()

	buttonCancel = setupNewButton("BOTTOM", 0, 20, 30, 20, "Cancel", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonCancel:SetScript("OnClick", function (self, button, down)
		buttonAPF:Hide()
		buttonAPN:Hide()
		buttonAP:Show()
		buttonCancel:Hide()
		buttonLists:Show()
	end)
	buttonCancel:Hide()

	button = setupNewButton("BOTTOMLEFT", 5, 0, 30, 20, "LAST", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		SlashCmdList.AUTOPLAY("last")
	end)

	button = setupNewButton("BOTTOMRIGHT", offset, 0, 30, 20, "NEXT", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		SlashCmdList.AUTOPLAY("next")
	end)

	button = setupNewButton("BOTTOM", width / 4, 0, 30, 20, "Stop", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		SlashCmdList.STOPSOUND()
	end)

	buttonPause = setupNewButton("BOTTOM", width / 4, 20, 30, 20, "Pause", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonPause:SetScript("OnClick", function (self, button, down)
		SlashCmdList.PAUSE()
	end)

	button = setupNewButton("BOTTOM", -(width / 4), 0, 30, 20, "Tracks", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		displayFrames(1)
	end)

	button = setupNewButton("TOPLEFT", 5, 0, 30, 20, "Help", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		displayFrames(2)
	end)
	
	buttonLists = setupNewButton("BOTTOM", 0, 20, 30, 20, "Lists", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonLists:SetScript("OnClick", function (self, button, down)
		buttonAP:Hide()
		buttonLists:Hide()
		buttonCancelLists:Show()
		buttonFavorite:Show()
		buttonBlacklist:Show()
	end)

	buttonCancelLists = setupNewButton("BOTTOM", 0, 0, 30, 20, "Cancel", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonCancelLists:SetScript("OnClick", function (self, button, down)
		buttonCancelLists:Hide()
		buttonFavorite:Hide()
		buttonBlacklist:Hide()
		buttonAP:Show()
		buttonLists:Show()
	end)
	buttonCancelLists:Hide()

	buttonFavorite = setupNewButton("BOTTOM", -30, 20, 30, 20, "Favorite", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonFavorite:SetScript("OnClick", function (self, button, down)
		buttonCancelLists:Hide()
		buttonFavorite:Hide()
		buttonBlacklist:Hide()
		buttonAP:Show()
		buttonLists:Show()
		addFavorite(currentTrackId)	
	end)
	buttonFavorite:Hide()

	buttonBlacklist = setupNewButton("BOTTOM", 30, 20, 30, 20, "Blacklist", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	buttonBlacklist:SetScript("OnClick", function (self, button, down)
		buttonCancelLists:Hide()
		buttonFavorite:Hide()
		buttonBlacklist:Hide()
		buttonAP:Show()
		buttonLists:Show()
		addBlacklist(currentTrackId)	
	end)
	buttonBlacklist:Hide()

	button = setupNewButton("BOTTOM", -(width / 4), 20, 30, 20, "Shuffle", em_miniUi, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		autoplayList = shuffle(autoplayList)
	end)
end

writeLines = function (new, frame)
	local position = 0
	local i = 0
	if frame == 1 then
		if searched then
			showSearchFrame()
		elseif showPlaylists or addTrackOngoing then
			showPlaylistFrame()
		elseif showFavorites then
			showFavoriteFrame()
		elseif showBlacklist then
			showBlacklistFrame()
		else
			if not addCustomTrackOngoing then
				if new then
					setupBase(frame)
				end
				buttonAddPl:SetText(L["Add Custom"])
				buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 320, -10)
				buttonAddPl:Show()
				for s in pairsByKeys(sounds) do
					i = i + 1
					if (i >= start[frame]) then
						position = position + 1
						if (i <= ending[frame]) then
							if new then
								setupBase2(frame, position, s)
							end
							local description = sounds[s].description
							local text = tostring(s) .. " - " .. tostring(description)
							strings[position]:SetText(text)
							buttons[position]:SetText(L["Play"])
							buttons[position]:Show()
							if favorites[s] ~= nil then
								buttonsF[position]:SetText(L["Remove"])
							else
								buttonsF[position]:SetText(L["Favorite"])
							end
							buttonsF[position]:Show()
							if blacklist[s] ~= nil then
								buttonsB[position]:SetText(L["Remove"])
								buttonsB[position]:Show()
							else	
								buttonsB[position]:SetText(L["Blacklist"])
								buttonsB[position]:Show()
							end
							buttonsAT[position]:SetText(L["Add to"])
							buttonsAT[position]:Show()
							if sounds[s].type == soundType.CUSTOM then
								buttonsD[position]:Show()
							else
								buttonsD[position]:Hide()
							end
						else
							break
						end
					end
				end
				while position < number[frame] do
					position = position + 1
					strings[position]:SetText("")
					buttons[position]:Hide()
					buttons[position]:SetText(L["Play"])
					buttonsF[position]:Hide()
					buttonsB[position]:Hide()
					buttonsAT[position]:Hide()
					buttonsD[position]:Hide()
				end
			else
				local i = 0
				while i < number[frame] do
					i = i + 1
					strings[i]:SetText("")
					editBox[i]:Hide()
					buttons[i]:Hide()
					buttonsF[i]:Hide()
					buttonsB[i]:Hide()
					buttonsAT[i]:Hide()
					buttonsD[i]:Hide()
				end	
				buttonAddPl:SetText(L["Back"])
				buttonAddPl:SetPoint("TOPLEFT", f[1]:GetWidth() - 295, -10)
				buttonAddPl:Show()
				strings[1]:SetText(L["Name:"])
				strings[1]:Show()
				editBox[1]:SetPoint("TOPLEFT", 250, ((size * -1) - size - titlesizeextra))
				editBox[1]:Show()
				strings[2]:SetText(L["Description:"])
				strings[2]:Show()
				editBox[2]:SetPoint("TOPLEFT", 250, ((size * -2) - size - titlesizeextra))
				editBox[2]:Show()
				strings[3]:SetText(L["Filename (without extension):"])
				strings[3]:Show()
				editBox[3]:SetPoint("TOPLEFT", 250, ((size * -3) - size - titlesizeextra))
				editBox[3]:Show()
				strings[4]:SetText(L["Length of track (in seconds):"])
				strings[4]:Show()
				editBox[4]:SetPoint("TOPLEFT", 250, ((size * -4) - size - titlesizeextra))
				editBox[4]:Show()
				buttonSubmitCustom:Show()
				return
			end
		end
	elseif frame == 2 then
		if new then
			setupBase(frame)
		end
		for s in pairsByKeys(commands) do
			i = i + 1
			if (i >= start[frame]) then
				position = position + 1
				if (i <= ending[frame]) then
					if new then
						setupBase2(frame, position, s)
					end
					local description = commands[s].description
					local text = tostring(s) .. " - " .. tostring(description)
					stringsC[position]:SetText(text)
				else
					break
				end
			end
		end
	end
end

local function commandNotExisting()
	print(L["For available commands use /"] .. shortcut .. " help")
end

local function only1to100()
	print(L["For adjusting volume only numbers between 1 and 100 (both inclusive) are viable"])
end

displayFrames = function(frame)
	if not shown[frame] then
		f[frame]:Show()
	else
		f[frame]:Hide()
	end
end

scroll = function(n, frame)
	if (frame == 1) then
		getLengthFrame()
	end

	if (number[frame] >= length[frame]) then
		start[frame] = 1
		ending[frame] = length[frame]
	elseif (n == 0) then
		start[frame] = 1
		ending[frame] = number[frame]
	else
		st = start[frame]
		len = length[frame]
		nu = number[frame]
		local dir = n / math.abs(n)
		local dif = ((len - (st + nu + n - 1)) * ((dir + 1) / 2)) + ((st + n - 1) * ((dir - 1) / 2))
		start[frame] = st + n + ((dif - ((math.abs(dif)) *  dir)) / 2)
		ending[frame] = start[frame] + nu - 1
		writeLines(false, frame)
	end
end

resume = function()
	paused = false
	if frameStatus["miniui"] then
		update = true
	end
end

playTrack = function(track)
	if(track.type == soundType.MUSIC) then
		SlashCmdList.STOPSOUND(nil, nil, true)
		if(not musicEnabled) then 
			SetCVar("Sound_EnableMusic", 1)
		end
		PlayMusic(track.sound)
  	elseif(track.type == soundType.SOUND) then
		SlashCmdList.STOPSOUND(nil, nil, true)
		if(not soundEnabled) then 
			SetCVar("Sound_EnableSFX", 1)
		end
		SetCVar("Sound_EnableMusic", 0)
		soundId = select(2, PlaySound(track.sound))
  	elseif(track.type == soundType.CUSTOM) then
		SlashCmdList.STOPSOUND(nil, nil, true)
		SetCVar("Sound_EnableMusic", 0)
		soundId = select(2, PlaySoundFile("Interface\\AddOns\\em\\Sounds\\"..track.sound.."."..track.format, "Master"))
  	end
	currentTrack = track.description
	for sound in pairs(sounds) do
		if sounds[sound].description == track.description then
			currentTrackId = sound
			if isDigit(sounds[sound].length) then
				songDurationBar:SetDuration(sounds[sound].length)
				songDurationBar:Start()
			end
			if heard[sound] ~= nil then
				heard[sound] = heard[sound] + 1
			else
				heard[sound] = 1
			end
		end
	end
	notResumable = false
	buttonCancelLists:Hide()
	buttonFavorite:Hide()
	buttonBlacklist:Hide()
	buttonAPF:Hide()
	buttonAPN:Hide()
	buttonCancel:Hide()
	buttonAP:Show()
	buttonLists:Show()
	log1000[1000] = track.sound
	i = 1000
	while i > 1 do
		i = i - 1
		log1000[i], log1000[i+1] = log1000[i+1], log1000[i]
	end
	if autoplay then
		if currentAutoplayPlaylist == "daily" then
			playlists["daily"].tracks[currentTrackId] = nil
			local i = 1
			while dailyList.tracks[i] ~= nil do
				if dailyList.tracks[i] == currentTrackId then
					dailyList.tracks[i] = nil
					i = i + 1
					while dailyList.tracks[i] ~= nil do
						dailyList.tracks[i], dailyList.tracks[i-1] = dailyList.tracks[i-1], dailyList.tracks[i]
						i = i + 1
					end
					writeLines(false, 1)
					break
				end
				i = i + 1
			end
		elseif currentAutoplayPlaylist == "suggestions" then
			playlists["suggestions"].tracks[currentTrackId] = nil
			local i = 1
			while suggestionList[i] ~= nil do
				if suggestionList[i] == currentTrackId then
					suggestionList[i] = nil
					i = i + 1
					while suggestionList[i] ~= nil do
						suggestionList[i], suggestionList[i-1] = suggestionList[i-1], suggestionList[i]
						i = i + 1
					end
					writeLines(false, 1)
					break
				end
				i = i + 1
			end
		end
	end
	if frameStatus["miniui"] then
		update = true
	end
end

playNext = function()
	if paused or (not autoplay and not autoplayFavorite) then
		return
	end
	if autoplayPosition > autoplaySize then
		autoplayPosition = 1
	end
	if queueUp then
		queue(nil, false)
	end
	playTrack(sounds[autoplayList[autoplayPosition]])
	wait(sounds[autoplayList[autoplayPosition]].length)
	autoplayPosition = autoplayPosition + 1
end

goBack = function()
	if paused or (not autoplay and not autoplayFavorite) then
		return
	end
	if (autoplayPosition > 2) then
		autoplayPosition = autoplayPosition - 2
	else
		autoplayPosition = autoplaySize
	end
	playNext()
end

local function updateUi()
	uiUpdater = CreateFrame("Frame")
	uiUpdater:SetScript("OnUpdate", function (...)
		if frameStatus["miniui"] then
			if update then
				if paused then 
					buttonPause:SetText(L["Resume"])
				else
					buttonPause:SetText(L["Pause"])
				end
				if blacklist[currentTrackId] ~= nil then
					buttonBlacklist:SetText("Remove")
				else
					buttonBlacklist:SetText("Blacklist")
				end
				if favorites[currentTrackId] ~= nil then
					buttonFavorite:SetText("Remove")
				else
					buttonFavorite:SetText("Favorite")
				end
				textMU2:SetText(currentTrack)
				update = false
			end
		end
	end)
end

local function createMiniUi()
	local height = 80
	local width = 400

	miniUi = CreateFrame("Frame","em_miniUi",UIParent)
	miniUi:SetFrameStrata("MEDIUM")
	miniUi:SetWidth(width)
	miniUi:SetHeight(height)

	miniUi:SetScript("OnHide", function()
		frameStatus["miniui"] = false
		songDurationBar:Hide()
	end)
	miniUi:SetScript("OnShow", function()
		frameStatus["miniui"] = true
		songDurationBar:Show()
	end)

	local t = miniUi:CreateTexture(nil,"HIGH")
	t:SetTexture("interface/dialogframe/ui-dialogbox-background.blp")
	t:SetAllPoints(miniUi)
	miniUi.texture = t
	miniUi:EnableMouse(true)
	miniUi:SetMovable(true)
	miniUi:RegisterForDrag("LeftButton")
	miniUi:SetScript("OnDragStart", miniUi.StartMoving)
	miniUi:SetScript("OnDragStop", miniUi.StopMovingOrSizing)
	miniUi:SetPoint("CENTER",0,0)
	miniUi:SetClampedToScreen(true)

	textMU = miniUi:CreateFontString(s)
	textMU:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE, MONOCHROME")
	textMU:SetPoint("TOP", 0, 0)
	textMU:SetText(L["Current/Last track:"])
	textMU2 = miniUi:CreateFontString(s)
	textMU2:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE, MONOCHROME")
	textMU2:SetPoint("TOP", 0, size * -1)

	songDurationBar = loadingBar:New(texture, width - 50, 8)
	songDurationBar:SetPoint("CENTER", em_miniUi, 0, 5)
	songDurationBar:SetColor(255, 255, 0, 1)
	songDurationBar.fill = 1
	songDurationBar:SetFrameStrata("HIGH")

	setupButtons(width)

	updateUi()

	if frameStatus["miniui"] then
		miniUi:Show()
	else
		miniUi:Hide()
	end
end

local function createFrame()
	local width
	local height
	local frame = 1
	while(frame <= 2) do
		if frame == 1 then
			width = 800
			height = 600
			window = "tracks"
		elseif frame == 2 then
			width = 800
			height = 400
			window = "help"
		end

		f[frame] = CreateFrame("Frame","em_mainFrame" .. frame,UIParent)
		f[frame]:SetFrameStrata("HIGH")
		f[frame]:SetWidth(width)
		f[frame]:SetHeight(height)
		
		local t = f[frame]:CreateTexture(nil,"HIGH")
		t:SetTexture("interface/dialogframe/ui-dialogbox-background.blp")
		t:SetAllPoints(f[frame])
		f[frame].texture = t
		number[frame] = round(((height - titlesizeextra) / size) - 4)
		start[frame] = 1
		ending[frame] = number[frame]
		writeLines(true, frame)
		f[frame]:EnableMouse(true)
		f[frame]:SetMovable(true)
		f[frame]:RegisterForDrag("LeftButton")
		f[frame]:SetScript("OnDragStart", f[frame].StartMoving)
		f[frame]:SetScript("OnDragStop", f[frame].StopMovingOrSizing)
		f[frame]:EnableMouseWheel(true)
		if frame == 1 then
			f[frame]:SetScript("OnHide", function()
				shown[1] = false
				searched = false
				searchString = nil
				showFavorites = false
				showBlacklist = false
				showPlaylists = false
				createPlaylistOngoing = false
				addTrackOngoing = false
				addCustomTrackOngoing = false
				editBox[1]:Hide()
				editBox[2]:Hide()
				editBox[3]:Hide()		
				editBox[4]:Hide()		
				buttonSubmit:Hide()
				buttonSubmitCustom:Hide()
				start[1] = 1
				ending[1] = number[1]
				local i = 0
			end)
			f[frame]:SetScript("OnShow", function()
				shown[1] = true
				writeLines(false, 1)
			end)
			f[frame]:SetScript("OnMouseWheel", function(event, direction)
				local n = round(number[1] / 4.5)
				if(direction == 1) then
					scroll((n * -1), 1)
				elseif(direction == -1) then
					scroll(n, 1)
				end
			end)
		elseif frame == 2 then
			f[frame]:SetScript("OnHide", function()
				shown[2] = false
				start[2] = 1
				scroll(0, 2)
			end)
			f[frame]:SetScript("OnShow", function()
				shown[2] = true
				writeLines(false, 2)
			end)
			f[frame]:SetScript("OnMouseWheel", function(event, direction)
				local n = round(number[2] / 4.5)
				if(direction == 1) then
					scroll((n * -1), 2)
				elseif(direction == -1) then
					scroll(n, 2)
				end
			end)
		end
		f[frame]:SetPoint("CENTER",0,0)
		f[frame]:SetClampedToScreen(true)
		f[frame]:Hide()
		shown[frame] = false
		frame = frame + 1
	end
end

local function createErrorFrame()
	local height = 50
	local width = 950
	errorFrame = CreateFrame("Frame","errorframe",UIParent)
	errorFrame:SetFrameStrata("DIALOG")
	errorFrame:SetWidth(width)
	errorFrame:SetHeight(height)

	local t = errorFrame:CreateTexture(nil,"TOOLTIP")
	t:SetTexture("interface/dialogframe/ui-dialogbox-background.blp")
	t:SetAllPoints(errorFrame)
	errorFrame.texture = t

	errorFrame:EnableMouse(true)
	errorFrame:SetMovable(true)
	errorFrame:RegisterForDrag("LeftButton")
	errorFrame:SetScript("OnDragStart", errorFrame.StartMoving)
	errorFrame:SetScript("OnDragStop", errorFrame.StopMovingOrSizing)

	errorString = errorFrame:CreateFontString(s)
	errorString:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE, MONOCHROME")
	errorString:SetPoint("TOP", 0, -20)

	local button = setupNewButton("TOPRIGHT", -5, 0, 30, 30, "Close", errorframe, "GameFontNormal", true, "AnyUp", nil)
	button:SetScript("OnClick", function (self, button, down)
		errorFrame:Hide()
	end)

	errorFrame:SetPoint("CENTER",0,0)
	errorFrame:SetClampedToScreen(true)

	errorFrame:Hide()
	return
end

showErrorFrame = function(errorText)
	errorString:SetText(L[errorText])
	errorFrame:Show()
end

local startUp = CreateFrame("FRAME")
startUp:RegisterEvent("ADDON_LOADED")
startUp:SetScript("OnEvent", function(tableA, event, addon)
	if addon == shortcut then
		if favorites == nil then
			favorites = {}
		end
		if playlists == nil then
			playlists = {}
		end
		if customs == nil then
			customs = {}
		end
		if blacklist == nil then
			blacklist = {}
		end
		if log1000 == nil then
			log1000 = {}
		end
		if dailyList == nil then
			dailyList = {}
		end
		if frameStatus == nil then
			frameStatus = {}
			frameStatus["hide"] = false
			frameStatus["miniui"] = true
		end
		if heard == nil then
			heard = {}
		end
		if suggestionList == nil then
			suggestionList = {}
		end
		for pl in pairs(playlists) do
			local playlist, playlist2 = strsplit(" ", pl, 2)
			if playlist2 ~= "" and playlist2 ~= nil then
				playlist2 = string.gsub(playlist2," ","")
				playlist = playlist .. " " .. playlist2
				playlists[playlist], playlists[pl] = playlists[pl], nil
			end
		end
		for c in pairs(customs) do
			local custom, custom2 = strsplit(" ", c, 2)
			if custom2 ~= "" and custom2 ~= nil then
				custom2 = string.gsub(custom2," ","")
				custom = custom .. " " .. custom2
				customs[custom], customs[c] = customs[c], nil;
			end
			local tracklength = tonumber(customs[custom].tracklength)
			sounds[custom] = {
				["sound"] = customs[custom].filename,
				["description"] = customs[custom].description,
				["type"] = soundType.CUSTOM,
				["length"] = tracklength,
				["format"] = customs[custom].format
			}
		end
		if dailyList.Next == nil or dailyList.Next <= GetServerTime() then
			getDailyList()
			getSuggestionList()
		end
		playlists["daily"] = nil
		playlists["daily"] = {
			["description"] = "Your daily playlist",
			["tracks"] = dailyList.tracks;
		}
		playlists["suggestions"] = nil
		playlists["suggestions"] = {
			["description"] = "Your daily suggestion list of never or close to never heard songs",
			["tracks"] = suggestionList;
		}
		createFrame()
		createMiniUi()
		createErrorFrame()
		emMI = LibStub("LibDataBroker-1.1"):NewDataObject("Execute Music", {
			type = "launcher",
			label = "execute Music",
			icon = 	"interface/icons/inv_sword_48",
			OnClick = function(_, button) if button == "LeftButton" then if not frameStatus["miniui"] then miniUi:Show() else miniUi:Hide() end elseif button == "RightButton" then frameStatus["hide"] = 1 LDBIcon:Hide("Execute Music") end end,
			OnTooltipShow = function( tt ) tt:AddLine( "|cFFFFFFFFExecute Music|r" ) tt:AddLine( "|cFFFFFFFFLeft-click to open/close miniui.|r" ) tt:AddLine( "|cFFFFFFFFRight-click to hide the Minimap Icon.|r" ) end,
		})
		LDBIcon:Register("Execute Music", emMI, frameStatus)
	end
end)

local stopping = CreateFrame("FRAME")
stopping:RegisterEvent("PLAYER_LOGOUT")
stopping:SetScript("OnEvent", function(tableA, event, addon)
	SlashCmdList.STOPSOUND()
end)

function SlashCmdList.STOPSOUND(msg, editbox, automatic, pausing)
	if(not musicEnabled) then 
		SetCVar("Sound_EnableMusic", 0)
	end
	StopMusic()
	if(soundId ~= nil) then
		if(musicEnabled) then 
			SetCVar("Sound_EnableMusic", 1)
		end
		if(not soundEnabled) then
			SetCVar("Sound_EnableSFX", 0)
		end
		StopSound(soundId)
		soundId = nil
  	end
	if not automatic and (autoplay or autoplayFavorite) then
		log1000[1] = nil
		local i = 0
		while i < 1000 do
			i = i + 1
			log1000[i], log1000[i+1] = log1000[i+1], log1000[i]
		end
		SlashCmdList.AUTOPLAY("off")
	end
	if not pausing then
		resume()
		notResumable = true
	end
	songDurationBar:Stop()
end

function SlashCmdList.PAUSE(msg, editbox)
	if not notResumable then
		paused = not paused
		if paused then
			SlashCmdList.STOPSOUND(nil, nil, true, true)
			waitUntil = math.huge
		else
			if autoplay or autoplayFavorite then
				if autoplayPosition > 1 then
					autoplayPosition = autoplayPosition - 1
				else
					autoplayPosition = autoplaySize
				end
				playNext()
			else
				playTrack(sounds[currentTrackId])
			end
		end
		if frameStatus["miniui"] then
			update = true
		end
	end
end

function SlashCmdList.AUTOPLAY(command, editbox)
	if command == "last" then
		if autoplay or autoplayFavorite and not paused then
			goBack()
		end
	elseif command == "next" then
		if autoplay or autoplayFavorite and not paused then
			log1000[1] = nil
			local i = 0
			while i < 1000 do
				i = i + 1
				log1000[i], log1000[i+1] = log1000[i+1], log1000[i]
			end
			playNext()
		end
	elseif command == "off" then
		autoplayFavorite = false
		autoplay = false
		autoplayList = {}
		currentAutoplayPlaylist = nil
		autoplaySize = 0
		autoplayPosition = 0
		resume()
		print(L["Autoplay off"])
	elseif command == "SetupNew" then
		autoplayList = {}
		autoplaySize = 0
		autoplayPosition = 0
		SlashCmdList.STOPSOUND(nil, nil, true, false)
	elseif command == "favorite" then
		local found = false
		for fav in pairs(favorites) do
			found = true
			break
		end
		if not found then
			showErrorFrame(L["No favorites set"])
			return
		end
		autoplayFavorite = not autoplayFavorite
		if not autoplayFavorite then
			SlashCmdList.AUTOPLAY("off")
		else
			autoplay = false
			local i = 0
			local foundO = true
			SlashCmdList.AUTOPLAY("SetupNew", nil)
			for track in pairs(favorites) do
				if sounds[track] == nil then
					favorites[track] = nil
					writeLines(false,1)
					foundO = false
				else
					i = i + 1
					autoplayList[i] = track
				end
			end
			if i == 0 then
				showErrorFrame(L["No tracks to play available"])
				return
			end
			if not foundO then
				showErrorFrame("Sorry for this but I had to remove some tracks, due to namechange or removal, from your list")
			end
			autoplaySize = i
			autoplayPosition = 1
			resume()
			autoplayList = shuffle(autoplayList)
			playNext()
			print(L["Favorite Autoplay on"])
		end
	else
		autoplay = (not autoplay)
		if autoplay then
			autoplayFavorite = false
			local i = 0
			SlashCmdList.AUTOPLAY("SetupNew", nil)
			for track in pairs(sounds) do
				if (sounds[track].type == soundType.MUSIC or sounds[track].type == soundType.CUSTOM) and blacklist[track] == nil then
					i = i + 1
					autoplayList[i] = track
				end
			end
			autoplaySize = i
			autoplayPosition = 1
			resume()
			autoplayList = shuffle(autoplayList)
			playNext()
			print(L["Autoplay on"])
		else
			SlashCmdList.AUTOPLAY("off")
		end
	end
end

function SlashCmdList.STARTSOUND(trackId, editbox)
  	if(trackId ~= nil) then
		local knownTrack = sounds[trackId] ~= nil
		if (knownTrack) then
			local track = sounds[trackId]
			if not autoplay and not autoplayFavorite then
				playTrack(track)
			else
				queue(trackId, true)
			end
		else
			print(trackId .. L[" - Doesn't exist /"] .. shortcut .. L[" tracks for all tracks"])
		end
  	else
		print(L["No track selected write /"] .. shortcut .. L[" tracks for all tracks"])
  	end
end

function SlashCmdList.MUSIC(command, editbox)
	if (command == "on") then
		SetCVar("Sound_EnableMusic", 1)
	elseif (command == "off") then
		SetCVar("Sound_EnableMusic", 0)
	elseif(command == "toggle") then
		local value
		if(not GetCVarBool("Sound_EnableMusic")) then
			value = 1
			print(L["Music on"])
		else
			value = 0
			print(L["Music off"])
		end
		SetCVar("Sound_EnableMusic", value)
	elseif(command == "+") then
		local volume = tonumber(GetCVar("Sound_MusicVolume")) + 0.05
		SetCVar("Sound_MusicVolume", volume)
		print(L["Musicvolume: "] .. round(volume*100))
		return
	elseif(command == "-") then
		local volume = tonumber(GetCVar("Sound_MusicVolume")) - 0.05
		SetCVar("Sound_MusicVolume", volume)
		print(L["Musicvolume: "] .. round(volume*100))
		return
	elseif(command == "volume") then
		print(L["Musicvolume: "] .. round(GetCVar("Sound_MusicVolume")*100))
		return
	elseif(tonumber(command) ~= nil and (tonumber(command) >= 1 and tonumber(command) <= 100)) then
		SetCVar("Sound_MusicVolume", (tonumber(command)/100))
		return
	elseif(tonumber(command) ~= nil) then
		only1to100()
	else
		commandNotExisting()
		return
	end
	musicEnabled = GetCVarBool("Sound_EnableMusic")
end

function SlashCmdList.AMBIENCE(command, editbox)
	if (command == "on") then
		SetCVar("Sound_EnableAmbience", 1)
	elseif (command == "off") then
		SetCVar("Sound_EnableAmbience", 0)
	elseif(command == "toggle") then
		local value
		if(not GetCVarBool("Sound_EnableAmbience")) then
			value = 1
			print(L["Ambience on"])
		else
			value = 0
			print(L["Ambience off"])
		end
		SetCVar("Sound_EnableAmbience", value)
	elseif(command == "+") then
		local volume = tonumber(GetCVar("Sound_AmbienceVolume")) + 0.05
		SetCVar("Sound_AmbienceVolume", volume)
		print(L["Ambiencevolume: "] .. round(volume*100))
	elseif(command == "-") then
		local volume = tonumber(GetCVar("Sound_AmbienceVolume")) - 0.05
		SetCVar("Sound_AmbienceVolume", volume)
		print(L["Ambiencevolume: "] .. round(volume*100))
	elseif(command == "volume") then
		print(L["Ambiencevolume: "] .. round(GetCVar("Sound_AmbienceVolume")*100))
	elseif(tonumber(command) ~= nil and (tonumber(command) >= 1 and tonumber(command) <= 100)) then
		SetCVar("Sound_AmbienceVolume", (tonumber(command)/100))
	elseif(tonumber(command) ~= nil) then
		only1to100()
	else
		commandNotExisting()
		return
	end
end

function SlashCmdList.DIALOG(command, editbox)
	if (command == "on") then
		SetCVar("Sound_EnableDialog", 1)
	elseif (command == "off") then
		SetCVar("Sound_EnableDialog", 0)
	elseif(command == "toggle") then
		local value
		if(not GetCVarBool("Sound_EnableDialog")) then
			value = 1
			print(L["Dialog on"])
		else
			value = 0
			print(L["Dialog off"])
		end
		SetCVar("Sound_EnableDialog", value)
	elseif(command == "+") then
		local volume = tonumber(GetCVar("Sound_DialogVolume")) + 0.05
		SetCVar("Sound_DialogVolume", volume)
		print(L["Dialogvolume: "] .. round(volume*100))
	elseif(command == "-") then
		local volume = tonumber(GetCVar("Sound_DialogVolume")) - 0.05
		SetCVar("Sound_DialogVolume", volume)
		print(L["Dialogvolume: "] .. round(volume*100))
	elseif(command == "volume") then
		print(L["Dialogvolume: "] .. round(GetCVar("Sound_DialogVolume")*100))
	elseif(tonumber(command) ~= nil and (tonumber(command) >= 1 and tonumber(command) <= 100)) then
		SetCVar("Sound_DialogVolume", (tonumber(command)/100))
	elseif(tonumber(command) ~= nil) then
		only1to100()
	else
		commandNotExisting()
		return
	end
end

function SlashCmdList.SFX(command, editbox)
	if (command == "on") then
		SetCVar("Sound_EnableSFX", 1)
	elseif (command == "off") then
		SetCVar("Sound_EnableSFX", 0)
	elseif(command == "toggle") then
		local value
		if(not GetCVarBool("Sound_EnableSFX")) then
			value = 1
			print(L["SFX on"])
		else
			value = 0
			print(L["SFX off"])
		end
		SetCVar("Sound_EnableSFX", value)
	elseif(command == "+") then
		local volume = tonumber(GetCVar("Sound_SFXVolume")) + 0.05
		SetCVar("Sound_SFXVolume", volume)
		print(L["SFXvolume: "] .. round(volume*100))
		return
	elseif(command == "-") then
		local volume = tonumber(GetCVar("Sound_SFXVolume")) - 0.05
		SetCVar("Sound_SFXVolume", volume)
		print(L["SFXvolume: "] .. round(volume*100))
		return
	elseif(command == "volume") then
		print(L["SFXvolume: "] .. round(GetCVar("Sound_SFXVolume")*100))
		return
	elseif(tonumber(command) ~= nil and (tonumber(command) >= 1 and tonumber(command) <= 100)) then
		SetCVar("Sound_SFXVolume", (tonumber(command)/100))
		return
	elseif(tonumber(command) ~= nil) then
		only1to100()
		return
	else
		commandNotExisting()
		return
	end
	soundEnabled = GetCVarBool("Sound_EnableMusic")
end

function SlashCmdList.EM(command, editbox)
	if (command == "help") then
		displayFrames(2)
	elseif (command == "tracks") then
		displayFrames(1)
	elseif (command == "minimap") then
		if frameStatus["hide"] then
			frameStatus["hide"] = false
			LDBIcon:Show("Execute Music")
		else
			frameStatus["hide"] = true
			LDBIcon:Hide("Execute Music")
		end
	else 
		commandNotExisting()
	end
end

function SlashCmdList.ENABLEALL(command, editbox)
	if (not GetCVarBool("Sound_EnableAllSound")) then
		SetCVar("Sound_EnableAllSound", 1)
	else
		SetCVar("Sound_EnableAllSound", 0)
	end
end

function SlashCmdList.MASTERVOLUME(command, editbox)
	if(command == "+") then
		local volume = tonumber(GetCVar("Sound_MasterVolume")) + 0.05
		SetCVar("Sound_MasterVolume", volume)
		print(L["Mastervolume: "] .. round(volume*100))
	elseif(command == "-") then
		local volume = tonumber(GetCVar("Sound_MasterVolume")) - 0.05
		SetCVar("Sound_MasterVolume", volume)
		print(L["Mastervolume: "] .. round(volume*100))
	elseif(command == "volume") then
		print(L["Mastervolume: "] .. round(GetCVar("Sound_MasterVolume")*100))
	elseif(tonumber(command) ~= nil and (tonumber(command) >= 1 and tonumber(command) <= 100)) then
		SetCVar("Sound_MasterVolume", (tonumber(command)/100))
	elseif(tonumber(command) ~= nil) then
		only1to100()
	else
		commandNotExisting()
		return
	end
end

function SlashCmdList.SONG(command, editbox)
	print(L["Current/Last track:"] .. " " .. currentTrack)
end

function SlashCmdList.MINI(command, editbox)
	if not frameStatus["miniui"] then
		miniUi:Show()
	else
		miniUi:Hide()
	end
end