local hyper = {"cmd", "alt", "ctrl"}
local shiftHyper = {"cmd", "alt", "ctrl", "shift"}

local function sendSystemKey(key)
	hs.eventtap.event.newSystemKeyEvent(key, true):post()
	hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

local media = {
   previous  = function() sendSystemKey("PREVIOUS") end,
   play      = function() sendSystemKey("PLAY") end,
   next      = function() sendSystemKey("NEXT") end,
   up        = function() sendSystemKey("SOUND_UP") end,
   down      = function() sendSystemKey("SOUND_DOWN") end,
   mute      = function() sendSystemKey("MUTE") end,
   brightup  = function() sendSystemKey("BRIGHTNESS_UP") end,
   brightdn  = function() sendSystemKey("BRIGHTNESS_DOWN") end,
}

-- itunes
hs.hotkey.bind(hyper, 'z', media.previous)
hs.hotkey.bind(hyper, 'x', media.play)
hs.hotkey.bind(hyper, 'c', media.next)

-- volume
hs.hotkey.bind(hyper, 'a', media.mute)
hs.hotkey.bind(hyper, 's', media.down, nil, media.down)
hs.hotkey.bind(hyper, 'd', media.up, nil, media.up)

-- brightness increment/decrement
hs.hotkey.bind(hyper, 'w', media.brightdn)
hs.hotkey.bind(hyper, 'e', media.brightup)

function setBrightness(diff)
return function()
hs.brightness.set(diff)
end
end

-- max/min brightness
hs.hotkey.bind(shiftHyper, 'w', setBrightness(5))
hs.hotkey.bind(shiftHyper, 'e', setBrightness(100))

