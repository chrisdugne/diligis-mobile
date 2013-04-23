-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

SERVER_URL = "http://192.168.0.4:9000" 

IMAGE_CENTER	= "IMAGE_CENTER";
IMAGE_TOP_LEFT 	= "IMAGE_TOP_LEFT";


LINKEDIN_CONSUMER_KEY 		= "nkdrs359t7ta";
LINKEDIN_CONSUMER_SECRET 	= "cixqyissLNH8fQ44";

-----------------------------------------------------------------------------------------
--- Corona's libraries
json 			= require "json"
widget 			= require "widget"
storyboard 		= require "storyboard"

---- Additional libs
ui 				= require "libs.ui"
xml 			= require "libs.Xml"
utils 			= require "libs.Utils"
linkedIn 		= require "libs.social.LinkedIn"

---- Server access Managers
accountManager 	= require "managers.AccountManager"

---- App Tools
router 			= require "tools.Router"
viewTools		= require "tools.ViewTools"
imagesManager 	= require "tools.ImagesManager"


-----------------------------------------------------------------------------------------

print("-----------------------------------------------------");

-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 

------------------------------------------

router.openTopHome();

------------------------------------------
