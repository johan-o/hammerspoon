require("windows")
require("mediaShortcuts")
require("functions")
require("applaunch")
-- require("resolutionSwitching")

hs.loadSpoon("FnMate")

-- refreshResolutions()-- Automatic Reloading on Changes
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" or file:sub(-5) == ".json" then
            doReload = true
        end
    end
    if doReload then
        hs.console.clearConsole()
        hs.reload()
    end
  end

  myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
  hs.notify.new({title="New Config loaded"}):send()