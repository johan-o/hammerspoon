-- Easy Definition for Hyper
local hyper = {"cmd", "alt", "ctrl"}
local shiftHyper = {"cmd", "alt", "ctrl", "shift"}

-- Hold Cmd-Q to quit all applications
cmdQDelay = 0.5
cmdQTimer = nil
cmdQAlert = nil


function cmdQCleanup()
  hs.alert.closeSpecific(cmdQAlert)
  cmdQTimer = nil
  cmdQAlert = nil
end

function stopCmdQ()
  if cmdQTimer then
    cmdQTimer:stop()
    cmdQCleanup()
  end
end

function startCmdQ()
  local app = hs.application.frontmostApplication()
  cmdQTimer = hs.timer.doAfter(cmdQDelay, function() app:kill(); cmdQCleanup() end)
  cmdQAlert = hs.alert("Hold to Quit " .. app:name(), true)
end

cmdQ = hs.hotkey.bind({"cmd"}, "q", startCmdQ, stopCmdQ)

-- Checking if I'm Online
function pingResult(object, message, seqnum, error)
  if message == "didFinish" then
    avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
    info ="Pinging " .. object:server()
    if avg == 0.0 then
      pingInfo = "No network"
    else
      pingInfo = "Average: " .. avg .. "ms"
    end
    hs.notify.new({title=info, informativeText=pingInfo, alwaysPresent=true}):send()
  end
end

hs.hotkey.bind(hyper, "p", function()hs.network.ping.ping("google.com", 5, 0.01, 1.0, "any", pingResult)end)
hs.hotkey.bind(shiftHyper, "p", function()hs.network.ping.ping("big.local", 5, 0.01, 1.0, "any", pingResult)end)

-- Show Volume & Audio IO
hs.hotkey.bind(hyper, "q", function()
  audioInput = hs.audiodevice.current(false)
  audioOutput = hs.audiodevice.current(false)

  hs.alert.show("O: " .. audioInput["name"] .. " @ " .. audioInput["volume"], 0.75)
end)

-- -- Airpods Battery
hs.hotkey.bind(shiftHyper, "q", function()
  allInfo = hs.battery.privateBluetoothBatteryInfo()

  local airPodsConnected = false
  for k,bluetoothInfo in pairs(allInfo) do
    if bluetoothInfo["isApple"] == "YES" and string.match(bluetoothInfo["name"], "AirPods") then
      info = bluetoothInfo["name"] 
      airPodsConnected = true;

      if (bluetoothInfo["batteryPercentCase"] ~= "0") then
        info = info .. "\nCase: " .. bluetoothInfo["batteryPercentCase"] .. "%"
      end
  
      info = info .. "\nL: " .. bluetoothInfo["batteryPercentLeft"] .. "%\t\tR: " ..
          bluetoothInfo["batteryPercentRight"] .. "%"
      hs.alert.show(info, 0.75)   
    end
  end

  if (not airPodsConnected) then
    hs.alert.show("AirPods not connected")
  end
end)

-- Caps Lock functionality 
caps = hs.menubar.new()

hs.hotkey.bind(shiftHyper, "space", function()
  hs.hid.capslock.toggle()

  if hs.hid.capslock.get() then
    caps:setTitle("0")
  else
    caps:setTitle("A")
  end
  hs.sound.getByFile("/Users/jmo/.hammerspoon/" .. state .. ".mp3"):play()
end)