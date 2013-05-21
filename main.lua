-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

APP_NAME 	= "Diligis"
APP_VERSION = "0.9.0"

-----------------------------------------------------------------------------------------

SERVER_URL 		= "http://192.168.0.8:9000" 
--SERVER_URL 		= "http://localhost:9000" 

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
--- Corona's libraries
json 				= require "json"
widget 			= require "widget"
storyboard 		= require "storyboard"

---- Additional libs
analytics 		= require("libs.google.Analytics")
xml 				= require "libs.Xml"
utils 			= require "libs.Utils"
linkedIn 		= require "libs.social.LinkedIn"
tripit 			= require "libs.social.Tripit"

---- Server access Managers
accountManager = require "managers.AccountManager"
eventManager 	= require "managers.EventManager"

---- App Tools
router 			= require "tools.Router"
imagesManager 	= require "tools.ImagesManager"
viewManager		= require "tools.ViewManager"

---- App views

header = display.newGroup()
menu = display.newGroup()

---- App globals

selectedTrip 		= nil
selectedEvent 		= nil

-----------------------------------------------------------------------------------------
print("-----------------------------------------------------");
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 
analytics.init(ANALYTICS_VERSION, ANALYTICS_TRACKING_ID, ANALYTICS_PROFILE_ID, APP_NAME, APP_VERSION)
router.openAppHome()

------------------------------------------