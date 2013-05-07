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

function toggleMenu()

	menu:toFront()
	
	if(menu.x == 0) then
		transition.to( menu,  { x = display.contentWidth + display.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	else
		transition.to( menu,  { x = 0, time = 400, transition = easing.outExpo } )
	end
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