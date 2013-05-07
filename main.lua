-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--SERVER_URL 		= "http://192.168.0.7:9000" 
SERVER_URL 		= "http://localhost:9000" 

-----------------------------------------------------------------------------------------

LINKEDIN_CONSUMER_KEY 		= "nkdrs359t7ta";
LINKEDIN_CONSUMER_SECRET 	= "cixqyissLNH8fQ44";

-----------------------------------------------------------------------------------------

IMAGE_CENTER		= "IMAGE_CENTER";
IMAGE_TOP_LEFT 	= "IMAGE_TOP_LEFT";

-----------------------------------------------------------------------------------------
--- Corona's libraries
json 				= require "json"
widget 			= require "widget"
storyboard 		= require "storyboard"

---- Additional libs
ui 				= require "libs.ui"
xml 				= require "libs.Xml"
utils 			= require "libs.Utils"
linkedIn 		= require "libs.social.LinkedIn"
tripit 			= require "libs.social.Tripit"

---- Server access Managers
accountManager 	= require "managers.AccountManager"
eventManager 	= require "managers.EventManager"

---- App Tools
router 			= require "tools.Router"
viewTools		= require "tools.ViewTools"
imagesManager 	= require "tools.ImagesManager"

---- App views

menu = display.newGroup()

-----------------------------------------------------------------------------------------

print("-----------------------------------------------------");

-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 

------------------------------------------

router.openTopHome();

------------------------------------------
