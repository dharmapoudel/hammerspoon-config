-----------------------------------------------------------------------------------
--/ initialize /--
-----------------------------------------------------------------------------------
local basePath = os.getenv("HOME") .. "/.hammerspoon/"
local imagePath = basePath .. 'assets/';


require 'battery'
require 'windows'
--require 'battigayo'
require 'cheatsheets'
require 'random'


-- reload configurations
----------------------------------------------------------
function reloadConfig()
	hs.alert.show("Config loaded")
	hs.reload()
end 

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R",  reloadConfig)
hs.pathwatcher.new(basePath, reloadConfig):start()