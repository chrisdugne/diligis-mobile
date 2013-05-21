-----------------------------------------------------------------------------------------
--
-- router.lua
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function openAppHome()
	
	--- analytics
	analytics.pageview("AppHome")
	--- 
	
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
	
	--- analytics
	analytics.pageview("Profile")
	--- 

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

	--- analytics
	analytics.pageview("Stream")
	--- 
	
	storyboard.gotoScene( "views.Stream" )
end

---------------------------------------------

function openTrips()
	lastBack = openTrips
	accountManager.refreshTripsFromServer()
end

function displayTrips()

	--- analytics
	analytics.pageview("Trips")
	--- 
	
	storyboard.gotoScene( "views.Trips" )
end

---------------------------------------------
--- TripDiligis + TripMessages

function openTripDiligis(back)
	
	--- analytics
	analytics.pageview("TripDiligis")
	--- 
	
	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}

	storyboard.gotoScene( "views.TripDiligis", options )
end

function openTripMessages(back)

	--- analytics
	analytics.pageview("TripMessages")
	--- 
	
	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}

	storyboard.gotoScene( "views.TripMessages", options )
end

---------------------------------------------

function openWriteMessage(event, requireDefaultText, back)
	
	--- analytics
	analytics.pageview("WriteMessage")
	--- 
	
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
