-----------------------------------------------------------------------------
--/ Battigayo Schedule /--
-----------------------------------------------------------------------------

local myGroup = 1;
local triads = {"cmd", "alt", "ctrl"}
local basePath = os.getenv("HOME") .. "/.hammerspoon/"
local imagePath = basePath .. 'assets/';

-- function getScheule()
--    local url = 'http://api.battigayo.com'
--    hs.http.asyncGet(url, nil, function(status, body)
--         local w = hs.json.decode(body)
--         cachedWeather = w
--         lastUpdate = os.time()
--    end)
-- end


-- local chooserChoices = {"Choice 1", "Choice 2", "Choice 3", "Choice 4"}

 chooserChoices = { }


function startBattigayo()
		createBattigayoMenu()
end


function createBattigayoMenu()
	local bgMenu = hs.menubar.new()
	bgMenu:setTitle("💡"):setTooltip("Battigayo")
	bgMenu:setClickCallback(selectGroup)
end


function selectGroup()
	test = hs.chooser.new(displayTest)
        :rows(7)
    test:choices(chooserChoices)
    test:show()
end


function displayTest(input)
	myGroup = input.uuid or myGroup
    hs.alert("Your group is set to "..myGroup, 2)
end




local status = nil
local data = nil
local headers = nil
local weekday = os.date("%A")
local lastUpdated = os.time()


function fetchBattigayoData()
	status, data, headers = hs.http.get('http://api.battigayo.com')
	data = hs.json.decode(data)[1]
	return status, data, headers
end


function populateChoices()
	status, json, headers = fetchBattigayoData()
	for i = 1, 7 do
		local group =  json["group_"..i]
		local day = group[string.lower(weekday)]
		local choice = {
			["text"] = "Group ".. i,
  			["subText"] = "Morning: "..day.morning.. " Evening: "..day.evening,
  			["uuid"] = tostring(i)
		}
		table.insert(chooserChoices, i, choice)
    end

end


function showBattigayoNotification()
	local group =  data["group_"..myGroup]
	local dayData = group[string.lower(weekday)]
	
	hs.notify.new({
	      title        = "Group "..myGroup.." Schedule".." Last Updated: "..data.updated.english,
	      informativeText     = "Morning: "..dayData.morning.. "\nEvening: "..dayData.evening
	    }):send()
end

populateChoices()
startBattigayo()
hs.hotkey.bind(triads, 'O', showBattigayoNotification)