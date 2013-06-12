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

function displayProfile(linkedinUID, userUID, back)
	
	--- analytics
	analytics.pageview("Profile")
	--- 

	local options = {
		params = {
			linkedinUID = linkedinUID,
			userUID 		= userUID,
			back 			= back or lastBack
		}
	}
	
	storyboard.gotoScene( "views.Profile", options )
end

---------------------------------------------

function openPeopleJourney(announcement, back)

	--- analytics
	analytics.pageview("PeopleJourney")
	--- 

	local options = {
		params = {
			announcement 	= announcement,
			back 				= back
		}
	}
	
	storyboard.gotoScene( "views.PeopleJourney", options )
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

function openJourneys(back)

	--- analytics
	analytics.pageview("Journeys")
	---
	--  
	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}
	
	storyboard.gotoScene( "views.Journeys", options )
end

function displayTrips()

	--- analytics
	analytics.pageview("Trips")
	--- 
	
	storyboard.gotoScene( "views.Trips" )
end

---------------------------------------------
--- JourneyDiligis + JourneyMessages

function openJourneyDiligis(back)
	
	--- analytics
	analytics.pageview("JourneyDiligis")
	--- 
	
	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}

	storyboard.gotoScene( "views.JourneyDiligis", options )
end

function openJourneyMessages(back)

	--- analytics
	analytics.pageview("JourneyMessages")
	--- 
	
	local options = {
		params = {
			back = backOrLastBack(back)
		}
	}

	storyboard.gotoScene( "views.JourneyMessages", options )
end

---------------------------------------------

function openWriteMessage(event, answer, back)
	
	--- analytics
	analytics.pageview("WriteMessage")
	--- 
	
	local options = {
		params = {
			event 	= event,
			answer 	= answer,
			back 		= back or lastBack
		}
	}

	storyboard.gotoScene( "views.WriteMessage", options )
end


function openMessages()
	
	--- analytics
	analytics.pageview("Messages")
	--- 
	
	lastBack = openMessages
	storyboard.gotoScene( "views.Messages" )
end

---------------------------------------------
