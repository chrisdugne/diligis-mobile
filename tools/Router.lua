-----------------------------------------------------------------------------------------
--
-- router.lua
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function openTopHome()
	storyboard.gotoScene( "views.TopHome" )
end

---------------------------------------------

function openHome()
	storyboard.gotoScene( "views.Home" )
end

---------------------------------------------

function openTrips()
	storyboard.gotoScene( "views.Trips" )
end

---------------------------------------------

function openFinder()
	storyboard.gotoScene( "views.Finder" )
end

---------------------------------------------

function openMessages()
	storyboard.gotoScene( "views.Messages" )
end

---------------------------------------------

function callServer(data, request, next)
	local serverUrl = SERVER_URL .. "/" .. request
	
	local headers = {}
	headers["Content-Type"] = "application/json"

	local params = {}
	params.headers = headers
	params.body = json.encode(data)

	network.request(serverUrl, "POST", next, params)
end