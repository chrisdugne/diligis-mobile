-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

SERVER_URL = "http://192.168.0.4:9000" 

IMAGE_CENTER = "IMAGE_CENTER";
IMAGE_TOP_LEFT = "IMAGE_TOP_LEFT";

-----------------------------------------------------------------------------------------
--- Corona's libraries
ui 				= require "ui"
json 			= require "json"
widget 			= require "widget"
storyboard 		= require "storyboard"

---- Additional libs
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

print("Here is Diligis !");

-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 

------------------------------------------

router.openTopHome();

------------------------------------------
