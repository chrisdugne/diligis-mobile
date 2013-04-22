-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

SERVER_URL = "http://192.168.0.4:9000" 

-----------------------------------------------------------------------------------------
--- Global libs

json = require "json"
xml = require "libs.Xml"
utils = require "libs.Utils"
router = require "tools.Router"
linkedIn = require "libs.social.LinkedIn"

----

imageLoader = require "libs.ImageLoader"
viewTools = require "tools.ViewTools"

----

accountManager = require "managers.AccountManager"

--- Corona's "widget" library
widget = require "widget"
storyboard = require "storyboard"

-----------------------------------------------------------------------------------------

print("Here is Diligis !");

-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
--display.setStatusBar( display.DefaultStatusBar )
display.setStatusBar( display.HiddenStatusBar ) 

------------------------------------------

router.openTopHome();

------------------------------------------
