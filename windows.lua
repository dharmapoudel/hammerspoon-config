------------------------------------------------------------------------------------
--/ window management /--
------------------------------------------------------------------------------------

local cmdalt   = {"cmd", "alt"}
local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "ctrl", "shift" }

-- disable animations
hs.window.animationDuration = 0.01

local appwindow = nil
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

--x, y, w, h, l, r, t, b
local halfWindowFrames = {
	Left	=	{0.0, 0.0, 0.5, 1.0, 00, 2.5, 00, 00},
	Right	=	{0.5, 0.0, 0.5, 1.0, 2.5, 00, 00, 00},
	Up		=	{0.0, 0.0, 1.0, 0.5, 00, 00, 00, 2.5},
	Down	=	{0.0, 0.5, 1.0, 0.5, 00, 00, 2.5, 00}
}


for key, frame in pairs(halfWindowFrames) do
	hs.hotkey.bind(mash, key, splitWindow(frame))
end

--x, y, w, h, l, r, t, b
local quarterWindowFrames = {
	Up		=	{0.0, 0.0, 0.5, 0.5, 00, 2.5, 00, 2.5},
	Right	=	{0.5, 0.0, 0.5, 0.5, 2.5, 00, 00, 2.5},
	Down	=	{0.5, 0.5, 0.5, 0.5, 2.5, 00, 2.5, 00},
	Left	=	{0.0, 0.5, 0.5, 0.5, 00, 2.5, 2.5, 00},
	--{0.25, 0.25, 0.5, 0.5, 00, 00, 00, 00}
}

for key, frame in pairs(quarterWindowFrames) do
	hs.hotkey.bind(cmdalt, key, splitWindow(frame))
end

hs.hotkey.bind( mash, ",",		splitWindow({0.0, 0.0, 0.3, 1.0, 00, 05, 00, 00}))
hs.hotkey.bind( mash, ".",		splitWindow({0.3, 0.0, 0.7, 1.0, 05, 00, 00, 00}))




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


hs.hotkey.bind( mashshift, "Up", maximizeWindow)


-- un/minimize window
----------------------------------------------------------
function toggleMinimize()
 	appwindow = hs.window.focusedWindow()

 	if not appwindow then 
 		appwindow = hs.window.frontmostWindow()
 	end

 	if appwindow:isMinimized() then
 		appwindow:unminimize()
 	else
 		appwindow:minimize()
 	end

end

hs.hotkey.bind( mashshift, "Down", toggleMinimize)


-- toggle fullscreen
----------------------------------------------------------
function toggleFullscreen()
 	appwindow = hs.window.frontmostWindow()
 	appwindow:toggleFullScreen()
end

hs.hotkey.bind( mashshift, "Right", toggleFullscreen)


-- toggle between windows
----------------------------------------------------------
function toggleAppWindows()
 	local win = hs.window.focusedWindow()
 	if not win then 
 		return 
 	end
 	win:application():hide()
end

hs.hotkey.bind( mashshift, "Left", toggleAppWindows)


-- close window
----------------------------------------------------------
function quitApp()
 	appwindow = hs.window.frontmostWindow()
 	appwindow:close()
end

hs.hotkey.bind( mash, "X", quitApp)


-----------------------------------------------------------

--[[local frameIndex = 1;
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
end]]
