-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------
--
--
-- Load the relevant LuaSocket modules (no additional files required for these)
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Load external button library (should be in the same folder as main.lua)
local ui = require("ui")

-----------------------------------------------------------------------------------------
-- Load the image from the network
--
-- Turn on the Activity Indicator showing download
--
function loadImage(url, fileName, x, y)
	-- Create local file for saving data
	local path = system.pathForFile( fileName, system.DocumentsDirectory )
	local myFile = io.open( path, "w+b" ) 

	native.setActivityIndicator( true )             -- show busy

	-- Request remote file and save data to local file
	http.request{ 
		url = url, 
		sink = ltn12.sink.file(myFile),
	-- Normally we would io.close(myFile) but ltn12.sink.file does this for us.
	}

	-- Call the showImage function after a short time dealy
	local show = function() return showImage( fileName, x, y ) end
	timer.performWithDelay( 400, show)
end

-----------------------------------------------------------------------------------------
-- Comes here after starting the HTTP image load
--
function showImage(fileName, x, y)

	-- We need to turn off the Activity Indicator in a different chunk
	native.setActivityIndicator( false )

	-- Display local file
	display.newImage(fileName, system.DocumentsDirectory, x, y);
end

