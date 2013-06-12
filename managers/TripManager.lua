-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

local webView

-----------------------------------------------------------------------------------------

PLACE 			= 1;
PLANE 			= 2;
TRAIN 			= 3;

-----------------------------------------------------------------------------------------

function createTrip()

	local trip = {
		name 			= "New trip",
		imageUrl 	= "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png",
		journeys 	= {} 
	}
	
	utils.postWithJSON({
		user 	= accountManager.user,
		trip 	= trip
	},
	
	SERVER_URL .. "/createTrip", 
	tripCreated)
end

function tripCreated( event )
	local trip = json.decode(event.response)
	table.insert(accountManager.user.trips, trip)
	
	accountManager.saveLocalData()
	
	router.openTrips()
end

-----------------------------------------------------------------------------------------

-- 
-- 
local afterCreateJourney 

--- requestToken reception
function openNewJourneyWindow(next)
	
	local firstJourney = #selectedTrip.journeys == 0

   analytics.event("Trip", "openJourneyWebView") 
	afterCreateJourney = next

	local url = SERVER_URL .. "/create?firstJourney=" .. tostring(firstJourney) 
	
	print(url)

	webView = native.newWebView( display.screenOriginX, display.screenOriginY + HEADER_HEIGHT, display.contentWidth, display.contentHeight - HEADER_HEIGHT)
	webView:addEventListener( "urlRequest", newJourneyListener )
	webView:request( url )

end

function closeAddJourneyWindow()
	if(webView) then
		webView:removeSelf()
		webView = nil;
	end
end

-----------------------------------------------------
--

function newJourneyListener( event )
	if string.find(string.lower(event.url), "addjourney") then
		
		webView:removeEventListener( "urlRequest", newJourneyListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.type == '0') then
      	analytics.event("Trips", "creationCancelled") 
		else
      	analytics.event("Trips", "addJourney")
      	local journey = {
      		type				= params["type"],
      		startTime		= params["startTime"],
      		endTime			= params["endTime"],
      		locationName	= params["locationName"],
      		locationLat		= params["locationLat"],
      		locationLon		= params["locationLon"],
      		number			= params["number"],
      		seat				= params["seat"],
      		railcar			= params["railcar"]
      	} 

      	createJourney(journey)
		end
		
		closeAddJourneyWindow()
	end

end

-----------------------------------------------------
--

function createJourney(journey)
	
	utils.postWithJSON({
		tripId 	= selectedTrip.tripId,
		journey 	= journey
	},
	
	SERVER_URL .. "/createJourney", 
	journeyCreated)
	
end

function journeyCreated( event )
	local journey = json.decode(event.response)
	table.insert(selectedTrip.journeys, journey)
	accountManager.saveLocalData()
	afterCreateJourney()
end