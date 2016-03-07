------------------------------------------------------------------------
------------------------------------------------------------------------
local w = require("hs.webview")
require "functions"


function getAllMenuItemsTable(t)
      local menu = {}
          for pos,val in pairs(t) do
              if(type(val)=="table") then
                  if(val['AXRole'] =="AXMenuBarItem" and type(val['AXChildren']) == "table") then
                      menu[pos] = {}
                      menu[pos]['AXTitle'] = val['AXTitle']
                      menu[pos][1] = getAllMenuItems(val['AXChildren'][1])
                  elseif(val['AXRole'] =="AXMenuItem" and not val['AXChildren']) then
                      if( val['AXMenuItemCmdModifiers'] ~='0' and val['AXMenuItemCmdChar'] ~='') then
                        menu[pos] = {}
                        menu[pos]['AXTitle'] = val['AXTitle']
                        menu[pos]['AXMenuItemCmdChar'] = val['AXMenuItemCmdChar']
                        menu[pos]['AXMenuItemCmdModifiers'] = val['AXMenuItemCmdModifiers']
                      end 
                  elseif(val['AXRole'] =="AXMenuItem" and type(val['AXChildren']) == "table") then
                      menu[pos] = {}
                      menu[pos][1] = getAllMenuItems(val['AXChildren'][1])
                  end
              end
          end
      return menu
end



function getAllMenuItems(t)
      local commandEnum = {
        [0] = '⌘',
        [1] = '⌘ + ⇧',
        [2] = '⌘ + ⌥',
        [3] = '⌘ + ⌥ + ⌃',
        [4] = '⌘ + ⌃',
        [5] = '⌘ + ⇧ + ⌃',
        [7] = '',
        [12] ='⌃',
        [13] ='⌃',

      }
      local menu = ""
          for pos,val in pairs(t) do
              if(type(val)=="table") then
                  menu = menu.."<ul class='col col"..pos.."'>"
                  if(val['AXRole'] =="AXMenuBarItem" and type(val['AXChildren']) == "table") then
                      menu = menu.."<li><strong>"..val['AXTitle'].."</strong></li>"
                      menu = menu.. getAllMenuItems(val['AXChildren'][1])
                  elseif(val['AXRole'] =="AXMenuItem" and not val['AXChildren']) then
                      if( val['AXMenuItemCmdModifiers'] ~='0' and val['AXMenuItemCmdChar'] ~='') then
                        menu = menu.."<li>"..commandEnum[val['AXMenuItemCmdModifiers']].." "..val['AXMenuItemCmdChar'].." "..val['AXTitle'].."</li>"
                      end 
                  elseif(val['AXRole'] =="AXMenuItem" and type(val['AXChildren']) == "table") then
                      menu = menu..getAllMenuItems(val['AXChildren'][1])
                  end
                menu = menu.."</ul>"
              end
          end
      return menu
end

--local focusedApp= hs.window.frontmostWindow():application()
local focusedApp = hs.application.frontmostApplication()
local appTitle = focusedApp:title()
local allMenuItems = focusedApp:getMenuItems();
local myMenuItems = getAllMenuItems(allMenuItems)
print("-------------------------------------------------")
print(appTitle)
print("-------------------------------------------------")
--print_r(focusedApp:getMenuItems())
print_r(myMenuItems)
print("-------------------------------------------------")

local cols =""


local htmlBegin = [[
<!DOCTYPE html>
<html>
<head>
<style type="text/css">
    *{margin:0; padding:0;}
    html, body{ 
      background-color:#eee;
      font-family: arial;
      font-size: 13px;
    }
    a{
      text-decoration:none;
      color:#000;
      font-size:13px;
    }
    ul, li{list-style: inside none; padding: 0 0 5px;}
    footer{
      position: fixed;
      bottom: 0;
      left: 0;
      right: 0;
      height: 48px;
      background-color:#eee;
    }
    header hr,
    footer hr {
      border: 0;
      height: 0;
      border-top: 1px solid rgba(0, 0, 0, 0.1);
      border-bottom: 1px solid rgba(255, 255, 255, 0.3);
    }
    .title{
        padding: 15px;
    }
    .content{
      padding: 0 0 15px;
      font-size:12px;
      overflow:hidden;
    }
    .content > .col{
      min-height:495px;
      float: left;
      width: 23%;
      padding:10px 0 0 20px;
      border-right: 1px solid #ccc;
    }
    .col:nth-child(4){
      border:none;
    }
    .col:nth-child(4):after{
      visibility: hidden;
      display: block;
      font-size: 0;
      content: " ";
      clear: both;
      height: 0;
    }
</style>
</head>
  <body>
    <header>
      <div class="title"><strong>]]..appTitle..[[</strong></div>
      <hr />
    </header>
    <div class="content">]]..myMenuItems..[[</div>
]]

local htmlEnd = [[
  <footer>
    <hr />
      <div class="content"> 
        <div class="col">
          by <a href="https://github.com/dharmapoudel" target="_parent">dharma poudel</a>
        </div>
      </div>
  </footer>
	<script type="text/javascript">
		function submitCmd() {
		    try {
		        webkit.messageHandlers.passItAlong.postMessage(document.forms["inputForm"]["cmd"].value);
		    } catch(err) {
		        console.log('The controller does not exist yet');
		    }
		    return ;
		}
    </script>
  </body>
</html>
]]

local ucc = w.usercontent.new("passItAlong"):injectScript({ source = [[
    function KeyPressHappened(e)
    {
      if (!e) e=window.event;
      var code;
      if ((e.charCode) && (e.keyCode==0)) {
        code = e.charCode ;
      } else {
        code = e.keyCode;
      }
//      console.log(code) ;
      if (code == 13) {
          submitCmd() ;
          return false ; // we handled it
      } else {
          return true ;  // we didn't handle it
      }
    }
    document.onkeypress = KeyPressHappened;
    ]], mainFrame = true, injectionTime = "documentStart"}):setCallback(function(input)
    -- print(inspect(input))
    local output, status, tp, rc = hs.execute(input.body)
    myView:html(htmlBegin..[[
        <hr>
        <table width="100%">
          <tr>
            <td>Status:</td><td>]]..tostring(status)..[[</td>
            <td>Type:</td><td>]]..tostring(tp)..[[</td>
            <td>RC:</td><td>]]..tostring(rc)..[[</td>
          </tr>
        </table>
        <hr>
        <pre>]]..output..[[</pre>
        <hr>
        <div align="right"><i>Executed at: ]]..os.date()..[[</i></div>
    ]]..htmlEnd)
end)


  local myView = {}

--hammerspoon://cheatsheet
hs.urlevent.bind("cheatsheet", function(eventName, params)
    myView = w.new({x = 100, y = 100, w = 1080, h = 600}, { developerExtrasEnabled = true }, ucc)
              :windowStyle("utility")
              :allowTextEntry(true)
              :closeOnEscape(true)
              :html(htmlBegin..htmlEnd)
              :allowGestures(true)
              :windowTitle("CheatSheets")
              :show()

  --myView:asHSDrawing():setAlpha(.98)--:setRoundedRectRadii(1.0, 1.0)
  --myView:asHSWindow()
    myView:asHSDrawing():setAlpha(.98)
end)

hs.hotkey.bind('', "Down", function() 
	if myView then
		myView:delete(true)
    myView=nil
	end
end)