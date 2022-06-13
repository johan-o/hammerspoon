-- Easy Definition for Hyper
local hyper = {"cmd", "alt", "ctrl"}
local shiftHyper = {"cmd", "alt", "ctrl", "shift"}

hs.window.animationDuration = 0   -- Disable Window Animations

-- Returns the current window and its frame (maximum usable size)
function winAndMaximum() 
   return hs.window.focusedWindow(), (hs.window.focusedWindow():screen()):frame()
end

-- quarters — returns a rectangle from given parameters
-- first — the first half to start (left for X, top for Y)
-- last — the last half to start in
function quarters(firstX, lastX, firstY, lastY)
   _, max = winAndMaximum()

   return hs.geometry.rect(
         max.x + firstX * max.w / 2,
         max.y + firstY * max.h / 2, 
         max.w / 2 * (lastX - firstX), 
         max.h / 2 * (lastY - firstY))
end

function quarters(firstX, lastX, firstY, lastY)
   _, max = winAndMaximum()

   return hs.geometry.rect(
         max.x + firstX * max.w / 2,
         max.y + firstY * max.h / 2, 
         max.w / 2 * (lastX - firstX), 
         max.h / 2 * (lastY - firstY))
end

-- Halves of Screen
hs.hotkey.bind(hyper, "H", function()
   win, _ = winAndMaximum()
   win:setFrame(quarters(0, 1, 0, 2))
end)

hs.hotkey.bind(hyper, "L", function()
   win, _ = winAndMaximum()
   win:setFrame(quarters(1, 2, 0, 2))
end)

hs.hotkey.bind(hyper, "J", function()
   local win, _ = winAndMaximum()
   win:setFrame(quarters(0, 2, 1, 2))
end)

hs.hotkey.bind(hyper, "K", function()
   win, _ = winAndMaximum()
   win:setFrame(quarters(0, 2, 0, 1))
end)

-- Quarters of Screen
hs.hotkey.bind({"cmd", "ctrl"}, "left", function()
   win, _ = winAndMaximum()
   win:setFrame(quarters(0, 1, 0, 1))
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "left", function()
   win, _ = winAndMaximum()
   win:setFrame(quarters(0, 1, 1, 2))
end)

hs.hotkey.bind({"cmd", "ctrl"}, "right", function()
   local win, _ = winAndMaximum()
   win:setFrame(quarters(1, 2, 0, 1))
end)

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "right", function()
   win, _ = winAndMaximum()
   win:setFrame(quarters(1, 2, 1, 2))
end)

-- Thirds of Screen
-- Returns a rect with given parameters
-- first — the start index (inclusive) 0 for leftmost, 2 for rightmost
-- last - end index (exclusive)
--    Ex: thirdRects(0, 1) will return leftmost third
function thirdRects(first, last) 
   _, max = winAndMaximum()

   return hs.geometry.rect(
         max.x + first * max.w / 3,
         max.y, 
         max.w / 3 * (last - first), 
         max.h)
end

hs.hotkey.bind({"alt", "ctrl"}, "D", function()
   local win, _ = winAndMaximum()
   win:setFrame(thirdRects(0, 1))
end)

hs.hotkey.bind({"alt", "ctrl"}, "F", function()
   local win, _ = winAndMaximum()
   win:setFrame(thirdRects(1, 2))
end)

hs.hotkey.bind({"alt", "ctrl"}, "G", function()
   local win, _ = winAndMaximum()
   win:setFrame(thirdRects(2, 3))
end)

hs.hotkey.bind({"alt", "ctrl"}, "E", function()
   local win, _ = winAndMaximum()
   win:setFrame(thirdRects(0, 2))
end)

hs.hotkey.bind({"alt", "ctrl"}, "T", function()
   local win, _ = winAndMaximum()
   win:setFrame(thirdRects(1, 3))
end)

-- Maximizes active window in active screen
hs.hotkey.bind(hyper, "F", function()
   local win, _ = winAndMaximum()
   win:maximize()
end)

-- Display Movement
-- Moves active window to display number d
function moveWindowToDisplay(d)
   return function()
      local displays = hs.screen.allScreens()
      local win = hs.window.focusedWindow()
      win:moveToScreen(displays[d], false, true)
   end
end

-- Tries to move window to displays
hs.hotkey.bind(hyper, "1", moveWindowToDisplay(1))
hs.hotkey.bind(hyper, "2", moveWindowToDisplay(2))
hs.hotkey.bind(hyper, "3", moveWindowToDisplay(3))

-- Cycles active window anticlockwise
hs.hotkey.bind(hyper, 'n', function()
   local win = hs.window.focusedWindow()
   local screen = win:screen()
   
   win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end)

-- Menu Bar item to toggle the layout of mail, calendar and reminders
-- layoutMCR = hs.menubar.new()
-- layoutMCR:setIcon(hs.image.imageFromPath("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebariCloud.icns"):setSize({w=20,h=20}), true)

function layoutQuarters(firstX, lastX, firstY, lastY, max)
   return hs.geometry.rect(
         max.x + firstX * max.w / 2,
         max.y + firstY * max.h / 2, 
         max.w / 2 * (lastX - firstX), 
         max.h / 2 * (lastY - firstY))
end

function clickedMCR()
   currentScreen = hs.screen.mainScreen()
   local max = hs.screen.primaryScreen():frame()

   windowLayout = {
      {"Calendar",      nil, nil, nil, nil, layoutQuarters(0, 1, 0, 2, max)},
      {"Mail",          nil, nil, nil, nil, layoutQuarters(1, 2, 0, 2, max)}
   }

   toggleWindowLayout(windowLayout)
end

function toggleWindowLayout(windowLayout) 
   hs.layout.apply(windowLayout)

   -- checking if frontmost app is one of those in the layout
   frontApp = hs.application.frontmostApplication():name()
   inFront = false

   -- recursing through all apps in layout
   for _, v in pairs(windowLayout) do
      if v[1] == frontApp then
         inFront = true
      end
   end

   for _, v in pairs(windowLayout) do
      if inFront then
         hs.application.find(v[1]):hide()
      else 
         hs.application.launchOrFocus(v[1])
      end
   end
end

-- if layoutMCR then
--    layoutMCR:setClickCallback(clickedMCR)
-- end
hs.hotkey.bind(shiftHyper, "m", clickedMCR)