local cmdalt   = {"cmd", "alt"}
local triads = {"cmd", "alt", "ctrl"}
local quards = {"cmd", "alt", "ctrl", "shift"}

local basePath = os.getenv("HOME") .. "/.hammerspoon/"
local imagePath = basePath .. 'assets/';

--require("statuslets")
require 'battery'
require 'battigayo'
require 'cheatsheets'
--require 'functions'
-----------------------------------------------------------------------------------
-- reload the config 
-----------------------------------------------------------------------------------
function reloadConfig()
	hs.alert.show("Config loaded")
	hs.reload()
end 

hs.hotkey.bind(triads, "R",  reloadConfig)
hs.pathwatcher.new(basePath, reloadConfig):start()


-----------------------------------------------------------------------------------
--/ shortcut to open applications /--
-----------------------------------------------------------------------------------
local appList = {
	a = 'Activity Monitor',
	d = 'Dictionary',
	f = "Finder",
	s = 'Sublime Text 2'
}

for key, app in pairs(appList) do
	hs.hotkey.bind(triads, key, function() hs.application.launchOrFocus(app) end)
end


------------------------------------------------------------------------------------
--/ wifi stuffs  /--
------------------------------------------------------------------------------------

local homeWifi = "HOME-2172"
local urlToLoad = "https://www.twitter.com"
local browser = "Safari"

hs.wifi.watcher.new(function()
	local ssid = hs.wifi.currentNetwork()

	-- alert when internet is connected/disconnected
	if not ssid then
		hs.alert.show("wifi disconnected")
	else
		hs.alert.show("wifi connected")
	end

	-- load the url when home wifi is connected
	if ssid == homeWifi then
		-- wait for few seconds
		hs.timer.doAfter(2, function()
			-- load the url
			hs.execute("open "..urlToLoad)
			-- lunch or focus the app
			hs.application.launchOrFocus(browser)
		end)
	end

end):start()

--toggle wifi 
hs.hotkey.bind(triads, "W", function()
	if hs.wifi.currentNetwork() == nil then
		os.execute("networksetup -setairportpower en1 on")
	else
		os.execute("networksetup -setairportpower en1 off")
	end
end)

------------------------------------------------------------------------------------
-- window management 
------------------------------------------------------------------------------------
-- disable animations
hs.window.animationDuration = 0.05

local appwindow = nil
local visiblewindows = nil
local frameCache = {}

--split windows based on 8 variables
----------------------------------------------------------
--x, y, w, h, l, r, t, b
function splitWindow(coords)
	return function()
		appwindow =  hs.window.frontmostWindow()

		local f = appwindow:frame()
		local max = appwindow:screen():frame()

		f.x = max.x + (max.w * coords[1]) + coords[5]
		f.y = max.y + (max.h * coords[2]) + coords[7]
		f.w = (max.w * coords[3]) - coords[5] - coords[6]
		f.h = (max.h * coords[4]) - coords[7] - coords[8]

		frameCache[appwindow:id()] = f
		appwindow:setFrame(f)
	end
end

local keyFrameTable = {
	Left	=	{0.0, 0.0, 0.5, 1.0, 00, 2.5, 00, 00},
	Right	=	{0.5, 0.0, 0.5, 1.0, 2.5, 00, 00, 00},
	Up		=	{0.0, 0.0, 1.0, 0.5, 00, 00, 00, 2.5},
	Down	=	{0.0, 0.5, 1.0, 0.5, 00, 00, 2.5, 00}
}


for key, frame in pairs(keyFrameTable) do
	hs.hotkey.bind(triads, key, splitWindow(frame))
end


hs.hotkey.bind( triads, ",",		splitWindow({0.0, 0.0, 0.3, 1.0, 00, 05, 00, 00}))
hs.hotkey.bind( triads, ".",		splitWindow({0.3, 0.0, 0.7, 1.0, 05, 00, 00, 00}))





local frameIndex = 1;
--x, y, w, h, l, r, t, b
function rotateWindow(windowFrames)
	return function()
		appwindow =  hs.window.frontmostWindow()

		local f = appwindow:frame()
		local max = appwindow:screen():frame()

		f.x = max.x + (max.w * windowFrames[frameIndex][1]) + windowFrames[frameIndex][5]
		f.y = max.y + (max.h * windowFrames[frameIndex][2]) + windowFrames[frameIndex][7]
		f.w = (max.w * windowFrames[frameIndex][3]) - windowFrames[frameIndex][5] - windowFrames[frameIndex][6]
		f.h = (max.h * windowFrames[frameIndex][4]) - windowFrames[frameIndex][7] - windowFrames[frameIndex][8]

		frameCache[appwindow:id()] = f
		appwindow:setFrame(f)
		frameIndex = (frameIndex % #windowFrames) + 1
	end
end


--x, y, w, h, l, r, t, b
local windowFrames = {
	{0.0, 0.0, 0.5, 0.5, 00, 2.5, 00, 2.5},
	{0.5, 0.0, 0.5, 0.5, 2.5, 00, 00, 2.5},
	{0.5, 0.5, 0.5, 0.5, 2.5, 00, 2.5, 00},
	{0.0, 0.5, 0.5, 0.5, 00, 2.5, 2.5, 00},
	{0.25, 0.25, 0.5, 0.5, 00, 00, 00, 00}
}

hs.hotkey.bind(triads, "1", rotateWindow(windowFrames))


-- toggle window between  normal size and max size
----------------------------------------------------------
function maximizeWindow()
	appwindow = hs.window.frontmostWindow()

	if frameCache[appwindow:id()] then
		appwindow:setFrame(frameCache[appwindow:id()])
    	frameCache[appwindow:id()] = nil
	else
    	frameCache[appwindow:id()] = appwindow:frame()
    	appwindow:maximize()
	end
end 

hs.hotkey.bind( cmdalt, "Up", maximizeWindow)


-- un/minimize window
----------------------------------------------------------
function toggleMinimize()
 	appwindow = hs.window.focusedWindow()

 	if not appwindow then 
 		appwindow = hs.window.frontmostWindow()
 		print(window:title())
 	end

 	if appwindow:isMinimized() then
 		appwindow:unminimize()
 	else
 		appwindow:minimize()
 	end

end

hs.hotkey.bind( cmdalt, "Down", toggleMinimize)


-- toggle fullscreen
----------------------------------------------------------
function toggleFullscreen()
 	appwindow = hs.window.frontmostWindow()
 	appwindow:toggleFullScreen()
end

hs.hotkey.bind( cmdalt, "Right", toggleFullscreen)


-- toggle between windows
----------------------------------------------------------
function toggleAppWindows()
 	local win = hs.window.focusedWindow()
 	if not win then 
 		return 
 	end
 	win:application():hide()
end

hs.hotkey.bind( cmdalt, "Left", toggleAppWindows)


-- close window
----------------------------------------------------------
function quitApp()
 	appwindow = hs.window.frontmostWindow()
 	appwindow:close()
end

hs.hotkey.bind( triads, "X", quitApp)


------------------------------------------------------------------------------------

-- alert wifi up/down speed if speed goes below x%
--function speedDroppedCallback()
--	ssid  = hs.wifi.currentNetwork()
--end


 -- for key, app in pairs(hs.application.runningApplications()) do
 -- 	--print("* "..app:title())
 -- 	for key, window in pairs(app:visibleWindows()) do
 -- 		--print("  --"..window:title())
 -- 	end 
 -- end 

--print(hs.application.frontmostApplication())
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- get all apps

-- Debug: for trying out snippets of code
-- function dbg()
--     apps = hs.application.runningApplications()
--     for appIndex=1,#apps do
--         app = apps[appIndex]
--         print( app:pid() .. ' ' .. app:title() )
--     end
-- end

-- dbg()
-- function listApps()
--     print('-- Listing Running Apps --');
--     hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:bundleID(), app:title()) end)
--     print('------------');
-- end



border = nil

function drawBorder()
    if border then
        border:delete()
    end

    local win = hs.window.focusedWindow()
    if win == nil then return end

    local f = win:frame()
    local fx = f.x - 2
    local fy = f.y - 2
    local fw = f.w + 4
    local fh = f.h + 4

    border = hs.drawing.rectangle(hs.geometry.rect(fx, fy, fw, fh))
    border:setStrokeWidth(4)
    --border:setFillColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=01})
    border:setStrokeColor({["red"]=0,["blue"]=0,["green"]=1,["alpha"]=1})
    border:setRoundedRectRadii(6.0, 6.0)
    border:setStroke(true):setFill(false)
    border:sendToBack():show()
end

-- drawBorder()

-- windows = hs.window.filter.new(nil)
-- windows:subscribe(hs.window.filter.windowCreated, function () drawBorder() end)
-- windows:subscribe(hs.window.filter.windowFocused, function () drawBorder() end)
-- windows:subscribe(hs.window.filter.windowMoved, function () drawBorder() end)
-- windows:subscribe(hs.window.filter.windowUnfocused, function () drawBorder() end)




-- Lets draw the bar, on as many screens as we have, across the top
function drawBottonBar()
	local activeWindow = hs.window.frontmostWindow()
    local frame = activeWindow:frame()
    local box = hs.drawing.rectangle(hs.geometry.rect(frame.x, frame.h+3, frame.w, 20))

    box:setFillColor({["red"]=0.1,["blue"]=0.1,["green"]=0.1,["alpha"]=0.5}):setFill(true):show()
    box:setRoundedRectRadii(1.0, 1.0)

	-- Create the iTunes box
    local text = hs.drawing.text(hs.geometry.rect(frame.x , frame.h+3, frame.w, 20), "Test")
 	-- Set the text color
    text:setTextColor({["red"]=1,["blue"]=1,["green"]=1,["alpha"]=1})
	-- Set the font size and font type
    text:setTextSize(14)
    text:setTextFont('Tamzen7x14')
    text:setClickCallback()
    text:show()

    box:setLevel(hs.drawing.windowLevels["floating"])
end

--drawBottonBar()

--hammerspoon://test1?someParam=hello
hs.urlevent.bind("test", function(eventName, params)
  if params["someParam"] then
    hs.alert.show(params["someParam"])
  else 
  	hs.alert.show("test")
  end
end)

--hs.hotkey.bind(triads, '.', hs.hints.windowHints)



