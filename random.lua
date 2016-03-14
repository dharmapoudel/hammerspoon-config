
local mash = {"cmd", "alt", "ctrl"}

-----------------------------------------------------------------------------------
--/ shortcut to open applications /--
-----------------------------------------------------------------------------------
local appList = {
	a = 'Activity Monitor',
	f = "Finder",
	s = 'Sublime Text 2'
}

for key, app in pairs(appList) do
	hs.hotkey.bind(mash, key, function() hs.application.launchOrFocus(app) end)
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
hs.hotkey.bind(mash, "W", function()
	if hs.wifi.currentNetwork() == nil then
		os.execute("networksetup -setairportpower en1 on")
	else
		os.execute("networksetup -setairportpower en1 off")
	end
end)

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

--hs.hotkey.bind(mash, '.', hs.hints.windowHints)



