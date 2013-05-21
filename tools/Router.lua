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

lastBack = function() router.openStream() end

function backOrLastBack(back)

	--- 'back' can be "event" here => a table => so back is "nil" in that case
	if back and type(back) ~= "table" then
		lastBack = back
	end
	
	return lastBack
end

---------------------------------------------

function displayProfile(linkedinUID, back)
	
	local options = {
		params = {
			linkedinUID = linkedinUID,
			back = back or lastBack
		}
	}
	
	storyboard.gotoScene( "views.Profile", options )
end

---------------------------------------------

function openStream()
	lastBack = openStream
	eventManager.getStream()
end

function displayStream()
	storyboard.gotoScene( "views.Stream" )
end

---------------------------------------------

function openTrips()
	lastBack = openTrips
	storyboard.gotoScene( "views.Trips" )
end

---------------------------------------------
--- TripDiligis + TripMessages

function openTripDiligis(back)
	
	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}

	storyboard.gotoScene( "views.TripDiligis", options )
end

function openTripMessages(back)

	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}

	storyboard.gotoScene( "views.TripMessages", options )
end

---------------------------------------------

function openWriteMessage(event, requireDefaultText, back)
	
	print("openWriteMessage")
	print(back)
	print(back or lastBack)
	
	local options = {
		params = {
			event = event,
			requireDefaultText = requireDefaultText,
			back = back or lastBack
		}
	}

	storyboard.gotoScene( "views.WriteMessage", options )
end

---------------------------------------------
