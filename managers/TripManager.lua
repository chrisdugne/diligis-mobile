-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

local webView
local isWebViewOpened

-----------------------------------------------------------------------------------------

DESTINATION 	= 1;
FLIGHT 			= 2;
TRAIN 			= 3;

-----------------------------------------------------------------------------------------

function openWebWindow(url, listener)
	print("opening " .. url)
	
	webView = native.newWebView( display.screenOriginX, display.screenOriginY + HEADER_HEIGHT, display.contentWidth, display.contentHeight - HEADER_HEIGHT)
	webView:addEventListener( "urlRequest", listener )
	webView:request( url )

	isWebViewOpened = true
end

function closeWebWindow()
	if(webView) then
		webView:removeSelf()
		webView = nil
		isWebViewOpened = false
	end
	
	router.openTrips()
end


-----------------------------------------------------------------------------------------
--- TRIP
-----------------------------------------------------------------------------------

function openNewTripWindow(next)
	
	if(isWebViewOpened) then
		return
	end
		
   analytics.event("Trip", "openTripWebView") 

	local url = SERVER_URL .. "/createTrip"
	openWebWindow(url, tripListener)
end

-----------------------------------------------------
--

function tripListener( event )
	if string.find(string.lower(event.url), "addtrip") then
		
		webView:removeEventListener( "urlRequest", tripListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "tripCreationCancelled") 
		else
      	analytics.event("Trip", "addTrip")

      	local trip = {
      		imageUrl 	= SERVER_URL .. "/assets/images/mobile/traveler.png",
				journeys 	= {} 
			}

			if(params["name"] 			~= "null") then trip.name 				= params["name"] 				end
			if(params["locationName"]	~= "null") then trip.locationName 	= params["locationName"] 	end
			if(params["locationLat"] 	~= "null") then trip.locationLat 	= params["locationLat"]  	end
			if(params["locationLon"] 	~= "null") then trip.locationLon 	= params["locationLon"]		end

      	createTrip(trip)
		end
		
		closeWebWindow()
	end

end


-----------------------------------------------------------------------------------------

function createTrip(trip)

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
	selectedTrip = trip
   openAddTransportWindow()
end

-----------------------------------------------------------------------------------------
--- TRANSPORT
-----------------------------------------------------------------------------------------

function openAddTransportWindow()
	
	if(isWebViewOpened) then
		return
	end
	
	isWebViewOpened = true
	
   analytics.event("Trip", "openAddTransportWebView") 

	local firstTransport = #selectedTrip.journeys == 1
	local previousEndTime = 0
	
	if(not firstTransport) then
		previousEndTime = selectedTrip.journeys[#selectedTrip.journeys].endTime
	end
	
	local url = SERVER_URL .. "/createTransport?firstTransport=" .. tostring(firstTransport) .. "&startTime=" .. tostring(previousEndTime) 
	openWebWindow(url, transportListener)

end

-----------------------------------------------------

function transportListener( event )

	print("transportListener", event.url)
	if string.find(string.lower(event.url), "addtransport") then
		
		webView:removeEventListener( "urlRequest", transportListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "transportCreationCancelled") 
		else
      	analytics.event("Trip", "addTransport")
      	local transport = {} 

			if(params["type"] 			~= "null") then transport.type 				= params["type"] 				end
			if(params["startTime"] 		~= "null") then transport.startTime 		= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then transport.endTime 			= params["endTime"] 			end
			if(params["number"] 			~= "null") then transport.number 			= params["number"]			end
			if(params["seat"]			 	~= "null") then transport.seat 				= params["seat"]				end
			if(params["railcar"]	 		~= "null") then transport.railcar 			= params["railcar"]	 		end
			if(params["onward"]	 		~= "null") then transport.onward 			= params["onward"] 	== "true" end

      	createTransport(transport)
		end
		
		closeWebWindow()
	end

end

-----------------------------------------------------
--

local onward
function createTransport(transport)
	
	onward = transport.onward

	utils.postWithJSON({
		tripId 	 = selectedTrip.tripId,
		transport = transport
	},
	
	SERVER_URL .. "/createTransport", 
	transportCreated)
	
end

function transportCreated( event )
	local transport = json.decode(event.response)
	
	print("------- transportCreated")
	utils.tprint(transport)
	
	table.insert(selectedTrip.journeys, transport)
	accountManager.saveLocalData()
	
	if(onward) then
   	openAddDestinationWindow()
   else
   	router.openTrips()
   end
end


-----------------------------------------------------------------------------------------
--- DESTINATION
-----------------------------------------------------------------------------------------

function openAddDestinationWindow()
	
	if(isWebViewOpened) then
		return
	end
	
	isWebViewOpened = true
	
   analytics.event("Trip", "openAddDestinationWindow") 


	print("------- openAddDestinationWindow")
	utils.tprint(selectedTrip.journeys)
	
	local previousEndTime = selectedTrip.journeys[#selectedTrip.journeys].endTime
	
	if(not previousEndTime) then
		previousEndTime = -1
	end
	
	local url = SERVER_URL .. "/createDestination?startTime=" .. tostring(previousEndTime) 
	openWebWindow(url, destinationListener)

end

-----------------------------------------------------

function destinationListener( event )
	
	print("destinationListener", event.url)
	if string.find(string.lower(event.url), "adddestination") then
		
		webView:removeEventListener( "urlRequest", destinationListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "destinationCreationCancelled") 
		else
      	analytics.event("Trip", "addDestination")
      	local destination = {} 

			if(params["startTime"] 		~= "null") then destination.startTime 			= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then destination.endTime 			= params["endTime"] 			end
			if(params["locationName"]	~= "null") then destination.locationName 		= params["locationName"] 	end
			if(params["locationLat"] 	~= "null") then destination.locationLat 		= params["locationLat"]  	end
			if(params["locationLon"] 	~= "null") then destination.locationLon 		= params["locationLon"]		end

      	createDestination(destination)
		end
		
		closeWebWindow()
	end

end

-----------------------------------------------------
--

function createDestination(destination)
	
	utils.postWithJSON({
		tripId 	 	= selectedTrip.tripId,
		destination = destination
	},
	
	SERVER_URL .. "/createDestination", 
	destinationCreated)
	
end

function destinationCreated( event )
	
	local destination = json.decode(event.response)

	print("------- destinationCreated")
	utils.tprint(destination)

	table.insert(selectedTrip.journeys, destination)
	accountManager.saveLocalData()
   openAddTransportWindow()
end

---- 
---- 
--local afterCreateJourney 
--
--function openNewJourneyWindow(next)
--	
--	if(isWebViewOpened) then
--		return
--	end
--		
--	isWebViewOpened = true
--	
--	local firstJourney = #selectedTrip.journeys == 0
--
--   analytics.event("Trip", "openJourneyWebView") 
--	afterCreateJourney = next
--
--	local url = SERVER_URL .. "/create?firstJourney=" .. tostring(firstJourney) 
--	
--	openWebWindow(url, journeyListener)
--
--end
--
-------------------------------------------------------
----
--
--function journeyListener( event )
--	if string.find(string.lower(event.url), "addjourney") then
--		
--		webView:removeEventListener( "urlRequest", newJourneyListener )
--		
--		local params = utils.getUrlParams(event.url);
--		
--		if(params.type == '0') then
--      	analytics.event("Trip", "journeyCreationCancelled") 
--		else
--      	analytics.event("Trip", "addJourney")
--      	local journey = {} 
--
--			if(params["type"] 			~= "null") then journey.type 				= params["type"] 				end
--			if(params["startTime"] 		~= "null") then journey.startTime 		= params["startTime"] 		end
--			if(params["endTime"] 		~= "null") then journey.endTime 			= params["endTime"] 			end
--			if(params["locationName"]	~= "null") then journey.locationName 	= params["locationName"] 	end
--			if(params["locationLat"] 	~= "null") then journey.locationLat 	= params["locationLat"]  	end
--			if(params["locationLon"] 	~= "null") then journey.locationLon 	= params["locationLon"]		end
--			if(params["number"] 			~= "null") then journey.number 			= params["number"]			end
--			if(params["seat"]			 	~= "null") then journey.seat 				= params["seat"]				end
--			if(params["railcar"]	 		~= "null") then journey.railcar 			= params["railcar"]	 		end
--
--      	createJourney(journey)
--		end
--		
--		closeWebWindow()
--	end
--
--end

-----------------------------------------------------
----
--
--function createJourney(journey)
--	
--	utils.tprint(journey)
--	
--	utils.postWithJSON({
--		tripId 	= selectedTrip.tripId,
--		journey 	= journey
--	},
--	
--	SERVER_URL .. "/createJourney", 
--	journeyCreated)
--	
--end
--
--function journeyCreated( event )
--	local journey = json.decode(event.response)
--	table.insert(selectedTrip.journeys, journey)
--	accountManager.saveLocalData()
--	afterCreateJourney()
--end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------