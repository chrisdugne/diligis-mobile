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
      	local journey = {} 

			if(params["type"] 			~= "null") then journey.type 				= params["type"] 				end
			if(params["startTime"] 		~= "null") then journey.startTime 		= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then journey.endTime 			= params["endTime"] 			end
			if(params["locationName"]	~= "null") then journey.locationName 	= params["locationName"] 	end
			if(params["locationLat"] 	~= "null") then journey.locationLat 	= params["locationLat"]  	end
			if(params["locationLon"] 	~= "null") then journey.locationLon 	= params["locationLon"]		end
			if(params["number"] 			~= "null") then journey.number 			= params["number"]			end
			if(params["seat"]			 	~= "null") then journey.seat 				= params["seat"]				end
			if(params["railcar"]	 		~= "null") then journey.railcar 			= params["railcar"]	 		end

      	createJourney(journey)
		end
		
		closeAddJourneyWindow()
	end

end

-----------------------------------------------------
--

function createJourney(journey)
	
	utils.tprint(journey)
	
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