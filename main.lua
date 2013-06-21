-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

APP_NAME 	= "Diligis"
APP_VERSION = "2.5"

-----------------------------------------------------------------------------------------

--SERVER_URL 		= "http://192.168.0.7:9000" 
SERVER_URL 		= "http://localhost:9000" 
--SERVER_URL 		= "http://diligis.herokuapp.com/" 

-----------------------------------------------------------------------------------------

LINKEDIN_CONSUMER_KEY 		= "nkdrs359t7ta";
LINKEDIN_CONSUMER_SECRET 	= "cixqyissLNH8fQ44";

-----------------------------------------------------------------------------------------

IMAGE_CENTER		= "IMAGE_CENTER";
IMAGE_TOP_LEFT 	= "IMAGE_TOP_LEFT";

-----------------------------------------------------------------------------------------

ANALYTICS_VERSION 		= 1
ANALYTICS_TRACKING_ID 	= "UA-40736136-1"
ANALYTICS_PROFILE_ID 	= "72169019"

-----------------------------------------------------------------------------------------

HEADER_HEIGHT 				= 32

-----------------------------------------------------------------------------------------
--- Corona's libraries
json 				= require "json"
widget 			= require "widget"
storyboard 		= require "storyboard"

---- Additional libs
analytics 		= require("libs.google.Analytics")
xml 				= require "libs.Xml"
utils 			= require "libs.Utils"
linkedIn 		= require "libs.social.LinkedIn"

---- Server access Managers
accountManager = require "managers.AccountManager"
eventManager 	= require "managers.EventManager"
tripManager 	= require "managers.TripManager"

---- App Tools
router 			= require "tools.Router"
imagesManager 	= require "tools.ImagesManager"
viewManager		= require "tools.ViewManager"

---- App views

header = display.newGroup()
menu = display.newGroup()

---- App globals

GLOBALS = {
   selectedTrip 		= nil,
   selectedJourney 	= nil,
   selectedEvent 		= nil
}

-----------------------------------------------------------------------------------------

--localData = utils.loadTable("localData.json")
--	
--if(not localData) then
--	localData = {user = {}, linkedin = {}}
--   utils.saveTable(localData, "localData.json")
--end
--
--if(not localData.user.pictureUrl) then
--	localData.user.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
--end
	
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 
analytics.init(ANALYTICS_VERSION, ANALYTICS_TRACKING_ID, ANALYTICS_PROFILE_ID, APP_NAME, APP_VERSION)
linkedIn.init(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, nil, nil);
--linkedIn.init(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET, localData.linkedin.accessToken, localData.linkedin.accessTokenSecret);

------------------------------------------

accountManager.user = {}
accountManager.user.isConnected = false
accountManager.user.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"

------------------------------------------

-- a appliquer dans un workflow de changement de user 
--if((not accountManager.user.linkedinUID or accountManager.user.linkedinUID == "none") and localData.linkedin.accessToken) then
--	print("deauthorise")
--	linkedIn.deauthorise() -- previous user might be connected
--end

------------------------------------------

router.openAppHome()

------------------------------------------
--- ANDROID BACK BUTTON

local function onKeyEvent( event )

   local phase = event.phase
   local keyName = event.keyName
   print( event.phase, event.keyName )

   if ( "back" == keyName and phase == "up" ) then
      if ( storyboard.currentScene == "splash" ) then
         native.requestExit()
      else
      	native.setKeyboardFocus( nil )
         router.lastBack()
      end
   end

   return true  --SEE NOTE BELOW
end

--add the key callback
Runtime:addEventListener( "key", onKeyEvent )