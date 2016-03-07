
local basePath = os.getenv("HOME") .. "/.hammerspoon/"
local imagePath = basePath .. 'assets/';

-- function listApps()
--     print('-- Listing Running Apps --');
--     hs.fnutils.each(hs.application.runningApplications(), function(app) print(app:bundleID(), app:title()) end)
--     print('------------');
-- end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function merge(firstTable, secondTable)

    local newTable = hs.fnutils.copy(firstTable);
    return hs.fnutils.concat(newTable, secondTable);
end

-- I find it a little more flexible than hs.inspect for developing
function print_r( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end





border = nil

function drawBorder()
    if border then
        border:delete()
    end

    local win = hs.window.focusedWindow()
    if win == nil then return end

    local f = win:frame()
    local fx = f.x - 3
    local fy = f.y - 3
    local fw = f.w + 6
    local fh = f.h + 6

    border = hs.drawing.rectangle(hs.geometry.rect(fx, fy, fw, fh))
    border:setStrokeWidth(8)
    border:setFillColor({["red"]=0,["blue"]=0.70,["green"]=0.55,["alpha"]=0.75})
    border:setStrokeColor({["red"]=0,["blue"]=0.70,["green"]=0.55,["alpha"]=0.75})
    border:setRoundedRectRadii(5.0, 5.0)
    border:setStroke(true):setFill(false)
    border:sendToBack():show()
end

-- drawBorder()

-- windows = hs.window.filter.new(nil)
-- windows:subscribe(hs.window.filter.windowCreated, function () drawBorder() end)
-- windows:subscribe(hs.window.filter.windowFocused, function () drawBorder() end)
-- windows:subscribe(hs.window.filter.windowMoved, function () drawBorder() end)
-- windows:subscribe(hs.window.filter.windowUnfocused, function () drawBorder() end)