require("windows")
require("config")
require("mediaShortcuts")
require("functions")
require("applaunch")
require("resolutionSwitching")

hs.loadSpoon("FnMate")

refreshResolutions()

hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "b", function() print(hs.battery.watts()) end)