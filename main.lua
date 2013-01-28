-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local json = require "json"
local google = require "libs.social.Google"
local linkedIn = require "libs.social.LinkedIn"

-----------------------------------------------------------------------------------------
print("Youhou !");

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

local function googleConnect( event )
	google.test();
end


local function linkedInConnect( event )
	linkedIn.init();
	linkedIn.authorise();
end


-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="First", up="images/icon1.png", down="images/icon1-down.png", width = 32, height = 32, onPress=onFirstView, selected=true },
	{ label="Second", up="images/icon2.png", down="images/icon2-down.png", width = 32, height = 32, onPress=onSecondView },
	{ label="Second", up="images/icon2.png", down="images/icon2-down.png", width = 32, height = 32, onPress=onSecondView },
	{ label="LinkedIn", up="images/icon2.png", down="images/icon2-down.png", width = 32, height = 32, onPress=linkedInConnect },
	{ label="Google", up="images/icon2.png", down="images/icon2-down.png", width = 32, height = 32, onPress=googleConnect },
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
}

-----------------------------------------------------------------------------------------

local function networkListener( event )
	if ( event.isError ) then
		print( "Network error!")
	else
		local data = json.decode( event.response )
		local styles = data.styles; 
		
		-- Go through the array in a loop
		for i in pairs(styles) do
			local style = styles[i] 
			print(style.name)
			
			-- create some text
			local styleName = display.newRetinaText( style.name, 0, 0, native.systemFont, 32 )
			styleName:setTextColor( 255 )	
			styleName:setReferencePoint( display.CenterReferencePoint )
			styleName.x = display.contentWidth * 0.5
			styleName.y = 225 + i*50;
		end
	end
end

onFirstView()	-- invoke first tab button's onPress event manually

--local json_file_by_get = jsonFile( network.request( "http://mapnify.herokuapp.com/getPublicData", "POST", networkListener ) )
--local json_file_by_get = jsonFile( network.request( "http://localhost:9000/getPublicData", "POST", networkListener ) )

-----------------------------------------------------------------------------------------


