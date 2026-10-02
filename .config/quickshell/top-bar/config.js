.pragma library

// Optional personal image. Missing files leave the avatar blank.
var HOME_DIR = Quickshell.env("HOME") || ""
var PROFILE_IMG = HOME_DIR + "/.config/quickshell/snes-hub/profile.jpg"
var PROFILE_NAME = "snes"

var TOP_GAP = 50
var RIGHT_GAP = 10
var PANEL_W = 340
var PANEL_H = 600

// Weather
var CACHE_HOME = Quickshell.env("XDG_CACHE_HOME") || (HOME_DIR + "/.cache")
var WEATHER_CACHE_PATH = CACHE_HOME + "/quickshell/weather.json"
var WEATHER_SCRIPT_PATH = HOME_DIR + "/.config/hypr/UserScripts/WeatherWrap.sh"

// Events
var EVENTS_CMD = "khal list now 1h --json title --json start-time 2>/dev/null || echo '[]'"

// Screenshot
var SNAP_CMD = "command -v grimblast >/dev/null && grimblast --notify copysave area || true"
