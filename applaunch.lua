local shiftHyper = {"cmd", "alt", "ctrl", "shift"}

function loadAppLaunchers(pathToFile) 
   loadAppLaunchers(pathToFile, false)
end

function loadAppLaunchers(pathToFile) 
   keyList = hs.json.read(pathToFile)

   -- adding existing bindings
   for key, app in pairs(keyList) do
      if key ~= "" then
         hs.hotkey.bind(shiftHyper, key, function() 
            local frontApp = hs.application.frontmostApplication():name()
            if string.match(frontApp, app) or string.match(app, frontApp) then
               hs.application.find(frontApp):hide()
            else
               hs.application.launchOrFocus(app) 
            end end)
         end
   end

end


loadAppLaunchers("~/.hammerspoon/apps.json")