local shiftHyper = {"cmd", "alt", "ctrl", "shift"}

function loadAppLaunchers(pathToFile) 
   loadAppLaunchers(pathToFile, false)
end

function loadAppLaunchers(pathToFile, changeEntries) 
   local affirmativeButton = "Add more bindings"
   local negativeButton = "Save Bindings"

   keyList = hs.json.read(pathToFile)

   -- adding more bindings
   if changeEntries == true then
      continueAdding = true

      while continueAdding do
         _, char = hs.dialog.textPrompt("Enter Shortcut Character", "")
         char = string.sub(char, 1, 1)
      
         selectedButton, application = hs.dialog.textPrompt(
               "Enter Application Name to Open", "with character" .. char, "",
                affirmativeButton, negativeButton, false)
         
         continueAdding = (selectedButton == affirmativeButton)

         keyList[char] = application
      end
      
      -- hs.json.write(keyList, "~/.hammerspoon/configs/applaunch.json", true, true)
   end

   -- adding bindings
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


loadAppLaunchers("~/.hammerspoon/configs/applaunch.json")