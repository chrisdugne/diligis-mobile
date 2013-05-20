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

function openStream(fromMenu)
	if(fromMenu) then 
		eventManager.getStream()
	else
   	storyboard.gotoScene( "views.Stream" )
	end
end

---------------------------------------------

function openTrips()
	storyboard.gotoScene( "views.Trips" )
end

---------------------------------------------

function openTripDiligis()
	storyboard.gotoScene( "views.TripDiligis" )
end

function openTripMessages()
	storyboard.gotoScene( "views.TripMessages" )
end

---------------------------------------------

function openWriteMessage(event, requireDefaultText)
	print("openWriteMessage")
	utils.tprint(event)
	print(requireDefaultText)
	local options = {
		params = {
			event = event,
			requireDefaultText = requireDefaultText
		}
	}
	storyboard.gotoScene( "views.WriteMessage", options )
end

---------------------------------------------
