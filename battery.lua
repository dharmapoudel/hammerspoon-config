-----------------------------------------------------------------------------------
--/ battery stuffs  /--
-----------------------------------------------------------------------------------

local imagePath =  os.getenv("HOME") .. '/.hammerspoon/assets/';
local showBatteryPercentage = false;

local battery = {
	rem = hs.battery.percentage(),
	source = hs.battery.powerSource(),
	icon = imagePath ..'battery-charging.pdf',
	title =  "Battery Status",
	sound = "Sosumi",
	min = 50
}


-- notify when battery is full
function notifyWhenBatteryFullyCharged()
	local currentPercentage = hs.battery.percentage()
	if currentPercentage == 100  and battery.rem ~= currentPercentage and battery.source == 'AC Power' then
		battery.rem = currentPercentage
		hs.notify.new({
	      title        = battery.title,
	      subTitle     = 'Charged completely!',
	      contentImage = battery.icon,
	      soundName    = battery.sound
	    }):send()
	end
end


-- notify when battery is less than 50%
function notifyWhenBatteryLow()
	local currentPercentage = hs.battery.percentage()
	if currentPercentage <= battery.min and battery.rem ~= currentPercentage and (currentPercentage % 5 == 0 ) then
		battery.rem = currentPercentage
		hs.notify.new({
	      title        = battery.title,
	      informativeText     = 'Battery left: '..battery.rem.."%\nPower Source: "..battery.source,
	      contentImage = battery.icon,
	       soundName    = battery.sound
	    }):send()
	end
end



-- alert battery source when it changes
function alertPowerSource()
	local currentPowerSource= hs.battery.powerSource()
	if battery.source ~= currentPowerSource then
		battery.source = currentPowerSource
		hs.alert.show(battery.source);	
	end
end



-- display battery percentage on menu bar
function showPercentageonNavbar()
	local menuItem = hs.menubar.new(true)
	local currentPercentage = hs.battery.percentage()
	local remBatteryString = string.format("%.0f", currentPercentage)
	menuItem:setTitle(remBatteryString.."%")
end



function watchBattery()
	if showBatteryPercentage then
		showPercentageonNavbar()
	end
	alertPowerSource()
	notifyWhenBatteryLow()
	notifyWhenBatteryFullyCharged()
end


-- start watching
hs.battery.watcher.new(watchBattery):start()