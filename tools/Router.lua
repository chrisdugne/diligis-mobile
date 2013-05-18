-----------------------------------------------------------------------------------------
--
-- router.lua
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function openAppHome()
	storyboard.gotoScene( "views.AppHome" )
end

---------------------------------------------

function openStream()
	storyboard.gotoScene( "views.Stream" )
end

---------------------------------------------

function openTrips()
	storyboard.gotoScene( "views.Trips" )
end

---------------------------------------------

function openTripDiligis()
	storyboard.gotoScene( "views.TripDiligis" )
end

---------------------------------------------

function openWriteMessage()
	storyboard.gotoScene( "views.WriteMessage" )
end

---------------------------------------------

function openMessages()
	storyboard.gotoScene( "views.Messages" )
end
