------------------------------------------------------------------------
--/ Cheatsheet Copycat /--
------------------------------------------------------------------------

local commandEnum = {
      [0] = '⌘',
      [1] = '⇧ ⌘',
      [2] = '⌥ ⌘',
      [3] = '^ ⌥ ⌘',
      [4] = '⌃ ⌘',
      [5] = '⇧ ⌃ ⌘',
      [7] = '',
      [12] ='⌃',
      [13] ='⌃',
    }

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
    local menu = ""
        for pos,val in pairs(t) do
            if(type(val)=="table") then
                
                if(val['AXRole'] =="AXMenuBarItem" and type(val['AXChildren']) == "table") then
                    menu = menu.."<ul class='col col"..pos.."'>"
                    menu = menu.."<li class='title'><strong>"..val['AXTitle'].."</strong></li>"
                    menu = menu.. getAllMenuItems(val['AXChildren'][1])
                    menu = menu.."</ul>"
                elseif(val['AXRole'] =="AXMenuItem" and not val['AXChildren']) then
                    if( val['AXMenuItemCmdModifiers'] ~='0' and val['AXMenuItemCmdChar'] ~='') then
                      menu = menu.."<li><div class='cmdModifiers'>"..commandEnum[val['AXMenuItemCmdModifiers']].." "..val['AXMenuItemCmdChar'].."</div><div class='cmdtext'>".." "..val['AXTitle'].."</div></li>"
                    end 
                elseif(val['AXRole'] =="AXMenuItem" and type(val['AXChildren']) == "table") then
                    menu = menu..getAllMenuItems(val['AXChildren'][1])
                end
              
            end
        end
    return menu
end

function generateHtml()
    --local focusedApp= hs.window.frontmostWindow():application()
    local focusedApp = hs.application.frontmostApplication()
    local appTitle = focusedApp:title()
    local allMenuItems = focusedApp:getMenuItems();
    local myMenuItems = getAllMenuItems(allMenuItems)

    local html = [[
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
              font-size:12px;
            }
            li.title{ text-align:center;}
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
            footer .content .col{
                border:none;
              }
            .col:nth-child(4){
              border:none;
            }
            li:after,
            .col:nth-child(4):after{
              visibility: hidden;
              display: block;
              font-size: 0;
              content: " ";
              clear: both;
              height: 0;
            }
            .cmdModifiers{
              width: 60px;
              padding-right: 15px;
              text-align: right;
              float: left;
              font-weight: bold;
            }
            .cmdtext{
              float: left;
              overflow: hidden;
              width: 165px;
            }
        </style>
        </head>
          <body>
            <header>
              <div class="title"><strong>]]..appTitle..[[</strong></div>
              <hr />
            </header>
            <div class="content">]]..myMenuItems..[[</div>

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

    return html
end
  



local myView = "test"

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "C", function() 
  if myView =="test" then
    myView = hs.webview.new({x = 100, y = 100, w = 1080, h = 600}, { developerExtrasEnabled = true })
      :windowStyle("utility")
      :allowTextEntry(true)
      :closeOnEscape(true)
      :html(generateHtml())
      :allowGestures(true)
      :windowTitle("CheatSheets")
      :show()
      --:asHSWindow()
      :asHSDrawing()
      :setAlpha(.98)
  else
    myView:delete()
    myView="test"
  end
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "D", function() 
   myView:close()
    myView=nil
end)