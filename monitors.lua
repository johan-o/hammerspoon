-- Easy Definition for Hyper
local hyper = {"cmd", "alt", "ctrl"}
local shiftHyper = {"cmd", "alt", "ctrl", "shift"}

-- Changing Screen Resolution 
maximumHeight = hs.json.read("~/.hammerspoon/conf/displayResolutions.json")

hs.hotkey.bind(hyper, "-", function()
  curr = hs.screen.mainScreen()
  old = curr:currentMode()

  lastMode = nil
  possibleModes = curr:availableModes()

  print(dump(possibleModes))
  
  -- bad resolutions
  for key,val in pairs(possibleModes) do
    if val["w"] <= old["w"]  or badScaleOrAspect(old, val) then 
      possibleModes[key] = nil
    end
  end

  min = {w=5000}
  for key,val in pairs(possibleModes) do
    if val["w"] < min["w"] then
      min = val
    end
  end

  changeResolution(min)
end)

-- lower resolution / zooming in
hs.hotkey.bind(hyper, "=", function()
  curr = hs.screen.mainScreen()
  old = curr:currentMode()

  lastMode = nil
  possibleModes = curr:availableModes()

  -- bad resolutions
  for key,val in pairs(possibleModes) do
    if val["w"] >= old["w"] or badScaleOrAspect(old, val) then -- wrong aspect ratio 
      possibleModes[key] = nil
    end
  end

  max = {w=-1}
  for key,val in pairs(possibleModes) do
    if val["w"] > max["w"] then
      max = val
    end
  end

  changeResolution(max)
end)

function badScaleOrAspect(old, new) 
  return new["scale"] ~= old["scale"] or 
      old["w"] / old["h"] ~= new["w"] / new["h"]
end

function clickChangeResolution(junk, data)
  curr = hs.screen.find(data["UUID"])
  changeResolution(data["data"])
end

function changeResolution(new) 
  print(dump(new))
  curr:setMode(new["w"], new["h"], new["scale"], new["freq"], new["depth"])

  refreshResolutions() -- to refresh the menu bar
end

function resolutionToString(res)
  info = res["w"] .. "x" .. res["h"]
  if res["scale"] == 2 then
    info = info .. " (HiDPI)"
  end
  return info
end

-- Need to implement proper resolution sorting
-- show current resolution in menu bar
-- pathToResIcon = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarDisplay.icns"

resolutionMenuBar = hs.menubar.new()
-- resolutionMenuBar:setIcon(hs.image.imageFromPath(pathToResIcon):setSize({w=20,h=20}), true)

function refreshResolutions()
  resolutionMenuBar:setTitle(resolutionToString(hs.screen.mainScreen():currentMode()))
  
  -- Drop-Down Menu    
  screenOptions = {}

  -- Makes the menus & Sub Menus
  for _, currentScreen in pairs(hs.screen.allScreens()) do
    if currentScreen:name() ~= nil then
      old = currentScreen:currentMode()
      
      possibleResolutions = {}
      i = 0
      
      for _,resolution in pairs(currentScreen:availableModes()) do
        if badScaleOrAspect(resolution, old) == false and
            checkUUID(currentScreen, resolution) then -- right aspect ratio and scale
          menuInfo = {
              title = resolutionToString(resolution),
              fn = clickChangeResolution,
              data = resolution,
              UUID = currentScreen:getUUID()
          }

          if old["w"] == resolution["w"] and old["h"] == resolution["h"] and old["scale"] == resolution["scale"] then
            menuInfo["checked"] = true
            menuInfo["disabled"] = true
          end

          possibleResolutions[resolutionToString(resolution)] = menuInfo
        end
      end

      -- sorting resolutions because lua SUCKS
      
      sortedResolutions = sortResolutionTable(possibleResolutions)

      currentScreenOptions = {
          title = currentScreen:name(),
          menu = sortedResolutions
      }

      screenOptions[currentScreen:name()] = currentScreenOptions
    end
  end
  resolutionMenuBar:setMenu(screenOptions)
end

function sortResolutionTable(possibles)
  sortedTable = {}
  i = 1
  while tableSize(possibles) > 0 do
    minimum = getMinimumResolution(possibles)
    possibles[resolutionToString(minimum["data"])] = nil
    sortedTable[i] = minimum
    i = i + 1
  end
  return sortedTable
end

function tableSize(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function getMinimumResolution(allResolutions) 
  min = {data={w=50000}}

  for k, v in pairs(allResolutions) do
    if v["data"]["w"] < min["data"]["w"] then
      min = v
      minWidth = v["data"]["w"]
    end
  end
  return min
end


function checkUUID(screen, resolution) 
  return maximumHeight[screen:getUUID()] == nil or
   maximumHeight[screen:getUUID()]["h"] >= resolution["h"]
end

if resolutionMenuBar then
   resolutionMenuBar:setClickCallback(refreshResolutions)
end

hs.screen.watcher.new(refreshResolutions):start()

hs.hotkey.bind(hyper, "m", refreshResolutions)

-- Dumps a table to a human readable string
function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ',\n'
     end
     return s .. '} '
  else
     return tostring(o)
  end
end
