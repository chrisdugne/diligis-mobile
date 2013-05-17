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

function toggleMenu()

	menu:toFront()
	
	if(menu.x == 0) then
		transition.to( menu,  { x = display.contentWidth + display.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	else
		transition.to( menu,  { x = 0, time = 400, transition = easing.outExpo } )
	end
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
