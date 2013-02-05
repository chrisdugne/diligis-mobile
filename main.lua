-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

SERVER_URL = "http://192.168.0.18:9000" 

-----------------------------------------------------------------------------------------

json = require "json"
xml = require "libs.Xml"
utils = require "libs.Utils"
linkedIn = require "libs.social.LinkedIn"

-----------------------------------------------------------------------------------------

imageLoader = require "libs.ImageLoader"
accountManager = require "managers.AccountManager"

-----------------------------------------------------------------------------------------

print("Here is Diligis !");

-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget = require "widget"
local storyboard = require "storyboard"


-- event listeners for tab buttons:
local function onFirstView( event )
	storyboard.gotoScene( "views.view1" )
end

local function onSecondView( event )
	storyboard.gotoScene( "views.view2" )
end

------------------------------------------

local function linkedInConnect()
	linkedIn.init();
	linkedIn.authorise(linkedInConnected);
end

function linkedInConnected()
	imageLoader.loadImage(linkedIn.data.profile.pictureUrl, "profile.png", 30, 30);
	accountManager.getAccount(linkedIn);
end

------------------------------------------

-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="First", up="images/icon1.png", down="images/icon1-down.png", width = 32, height = 32, onPress=onFirstView, selected=true },
	{ label="Second", up="images/icon2.png", down="images/icon2-down.png", width = 32, height = 32, onPress=onSecondView },
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
--	top = 0;
	buttons = tabButtons
}

local clickLinkedInButton = function() return linkedInConnect() end;
button1 = ui.newButton{default="images/buttons/buttonArrow.png", over="images/buttons/buttonArrowOver.png", onRelease=clickLinkedInButton, x = 30, y = 50}
	
-----------------------------------------------------------------------------------------

onFirstView()

-----------------------------------------------------------------------------------------

--local function networkListener( event )
--	if ( event.isError ) then
--		print( "Network error!")
--	else
--		local data = json.decode( event.response )
--		local styles = data.styles; 
--		
--		-- Go through the array in a loop
--		for i in pairs(styles) do
--			local style = styles[i] 
--			print(style.name)
--			
--			-- create some text
--			local styleName = display.newRetinaText( style.name, 0, 0, native.systemFont, 32 )
--			styleName:setTextColor( 255 )	
--			styleName:setReferencePoint( display.CenterReferencePoint )
--			styleName.x = display.contentWidth * 0.5
--			styleName.y = 225 + i*50;
--		end
--	end
--end

--local json_file_by_get = jsonFile( network.request( "http://mapnify.herokuapp.com/getPublicData", "POST", networkListener ) )
--local json_file_by_get = jsonFile( network.request( "http://localhost:9000/getPublicData", "POST", networkListener ) )

-----------------------------------------------------------------------------------------


