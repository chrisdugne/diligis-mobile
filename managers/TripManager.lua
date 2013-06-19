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
	
	webView = native.newWebView( display.screenOriginX, display.screenOriginY + HEADER_HEIGHT, display.contentWidth, display.contentHeight - HEADER_HEIGHT)
	webView:addEventListener( "urlRequest", listener )
	webView:request( url )

	isWebViewOpened = true
end

function closeWebWindow(openTrips)
	if(webView) then
		webView:removeSelf()
		webView = nil
		isWebViewOpened = false
	end
	
	if(openTrips) then
		router.openTrips()
	end
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
	GLOBALS.selectedTrip = trip
   openAddTransportWindow()
end

-----------------------------------------------------------------------------------------
--- TRANSPORT
-----------------------------------------------------------------------------------------

function openAddTransportWindow()
	
	if(isWebViewOpened) then
		return
	end
	
   analytics.event("Trip", "openAddTransportWebView") 

	local firstTransport = #GLOBALS.selectedTrip.journeys == 1
	local previousEndTime = 0
	
	if(not firstTransport) then
		previousEndTime = GLOBALS.selectedTrip.journeys[#GLOBALS.selectedTrip.journeys].endTime
	end
	
	local url = SERVER_URL .. "/createTransport?firstTransport=" .. tostring(firstTransport) .. "&startTime=" .. tostring(previousEndTime) 
	openWebWindow(url, transportListener)

end

-----------------------------------------------------

function transportListener( event )

	if string.find(string.lower(event.url), "addtransport") then
		
		webView:removeEventListener( "urlRequest", transportListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "transportCreationCancelled") 
   		closeWebWindow(true)
		else
      	analytics.event("Trip", "addTransport")
      	local transport = {} 

			if(params["type"] 			~= "null") then transport.type 				= tonumber(params["type"]) end
			if(params["startTime"] 		~= "null") then transport.startTime 		= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then transport.endTime 			= params["endTime"] 			end
			if(params["number"] 			~= "null") then transport.number 			= params["number"]			end
			if(params["seat"]			 	~= "null") then transport.seat 				= params["seat"]				end
			if(params["railcar"]	 		~= "null") then transport.railcar 			= params["railcar"]	 		end
			if(params["onward"]	 		~= "null") then transport.onward 			= params["onward"] 	== "true" end

      	createTransport(transport)
   		closeWebWindow()
		end
		
	end

end

-----------------------------------------------------
--

local onward
function createTransport(transport)
	
	onward = transport.onward

	utils.postWithJSON({
		tripId 	 = GLOBALS.selectedTrip.tripId,
		transport = transport
	},
	
	SERVER_URL .. "/createTransport", 
	transportCreated)
	
end

function transportCreated( event )
	local transport = json.decode(event.response)
	
	table.insert(GLOBALS.selectedTrip.journeys, transport)
	
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
	
   analytics.event("Trip", "openAddDestinationWindow") 
	
	local previousEndTime = GLOBALS.selectedTrip.journeys[#GLOBALS.selectedTrip.journeys].endTime
	
	if(not previousEndTime) then
		previousEndTime = -1
	end
	
	local url = SERVER_URL .. "/createDestination?startTime=" .. tostring(previousEndTime) 
	openWebWindow(url, destinationListener)

end

-----------------------------------------------------

function destinationListener( event )
	
	if string.find(string.lower(event.url), "adddestination") then
		
		webView:removeEventListener( "urlRequest", destinationListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "destinationCreationCancelled") 
   		closeWebWindow(true)
		else
      	analytics.event("Trip", "addDestination")
      	local destination = {} 

			if(params["startTime"] 		~= "null") then destination.startTime 			= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then destination.endTime 			= params["endTime"] 			end
			if(params["locationName"]	~= "null") then destination.locationName 		= params["locationName"] 	end
			if(params["locationLat"] 	~= "null") then destination.locationLat 		= params["locationLat"]  	end
			if(params["locationLon"] 	~= "null") then destination.locationLon 		= params["locationLon"]		end

      	createDestination(destination)
   		closeWebWindow()
		end
	end
end

-----------------------------------------------------
--

function createDestination(destination)
	
	utils.postWithJSON({
		tripId 	 	= GLOBALS.selectedTrip.tripId,
		destination = destination
	},
	
	SERVER_URL .. "/createDestination", 
	destinationCreated)
	
end

function destinationCreated( event )
	
	local destination = json.decode(event.response)

	table.insert(GLOBALS.selectedTrip.journeys, destination)
   openAddTransportWindow()
end

-----------------------------------------------------

local afterDeleteJourney
function deleteJourney(index, next)
	
	afterDeleteJourney = next

	utils.postWithJSON({
		tripId 		= GLOBALS.selectedTrip.tripId,
		journeyId 	= GLOBALS.selectedTrip.journeys[index].journeyId
	},
	SERVER_URL .. "/deleteJourney", 
	journeyDeleted)

	table.remove(GLOBALS.selectedTrip.journeys, index)
	
end

function journeyDeleted( event )
	afterDeleteJourney()
end

-----------------------------------------------------------------------------------------
---  EDITION
-----------------------------------------------------------------------------------------

function addJourney()

	if(isWebViewOpened) then
		return
	end

	if(GLOBALS.selectedTrip.journeys[#GLOBALS.selectedTrip.journeys].type == DESTINATION) then
		openAddTransportWindow()
	else
		openAddDestinationWindow()
	end
end

function editJourney(next)

	if(isWebViewOpened) then
		return
	end

	if(GLOBALS.selectedJourney.type == DESTINATION) then
		openEditDestinationWindow(GLOBALS.selectedJourney, next)
	else
		openEditTransportWindow(GLOBALS.selectedJourney, next)
	end
end

-----------------------------------------------------------------------------------------
--- TRANSPORT
-----------------------------------------------------------------------------------------

local afterTransportEdition 

function openEditTransportWindow(tranport, next)
	
	afterTransportEdition 	= next
	
	local lastTransport = GLOBALS.selectedTrip.journeys[#GLOBALS.selectedTrip.journeys].journeyId == GLOBALS.selectedJourney.journeyId
	
   analytics.event("Trip", "openEditTransportWindow") 

	local url = SERVER_URL .. "/editTransport" 		.. 
	"?startTime=" 	.. tostring(tranport.startTime) 	.. 
	"&endTime=" 	.. tostring(tranport.endTime)		.. 
	"&type=" 		.. tostring(tranport.type)			.. 
	"&number=" 		.. tostring(tranport.number)		.. 
	"&seat=" 		.. tostring(tranport.seat)			.. 
	"&railcar=" 	.. tostring(tranport.railcar)		.. 
	"&lastTransport=" .. tostring(lastTransport)		.. 
	"&onward=" 		.. tostring(GLOBALS.selectedTrip.journeys[#GLOBALS.selectedTrip.journeys].journeyId ~= tranport.journeyId)
	
	openWebWindow(url, editTransportListener)

end

-----------------------------------------------------

function editTransportListener( event )

	if string.find(string.lower(event.url), "transportedited") then
		
		webView:removeEventListener( "urlRequest", editTransportListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "transportEditionCancelled") 
		else
      	analytics.event("Trip", "editTransport")

			if(params["startTime"] 		~= "null") then GLOBALS.selectedJourney.startTime 		= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then GLOBALS.selectedJourney.endTime 		= params["endTime"] 			end
			if(params["type"]	 			~= "null") then GLOBALS.selectedJourney.type 			= tonumber(params["type"]) end
			if(params["number"] 			~= "null") then GLOBALS.selectedJourney.number 			= params["number"]			end
			if(params["seat"]			 	~= "null") then GLOBALS.selectedJourney.seat 			= params["seat"]				end
			if(params["railcar"]	 		~= "null") then GLOBALS.selectedJourney.railcar 		= params["railcar"]	 		end
			if(params["onward"]	 		~= "null") then GLOBALS.selectedJourney.onward 			= params["onward"] 	== "true" end

      	editTransport()
		end
		
		closeWebWindow(false)
	end

end

-----------------------------------------------------
--

function editTransport()
	
	utils.postWithJSON({
		journey = GLOBALS.selectedJourney
	},
	
	SERVER_URL .. "/editJourney", 
	transportEdited)
	
end

function transportEdited( event )
	local onward = GLOBALS.selectedJourney.onward
	
	GLOBALS.selectedJourney = json.decode(event.response)
	
	if(onward) then
   	openAddDestinationWindow()
   else
   	afterTransportEdition()
   end
end


-----------------------------------------------------------------------------------------
--- DESTINATION
-----------------------------------------------------------------------------------------

local afterDestinationEdition 

function openEditDestinationWindow(destination, next)
	
	afterDestinationEdition 	= next
	
	if(isWebViewOpened) then
		return
	end
	
   analytics.event("Trip", "openEditDestinationWindow") 
	
	local url = SERVER_URL .. "/editDestination" 			.. 
	"?startTime=" 	.. tostring(destination.startTime) 		.. 
	"&endTime=" 	.. tostring(destination.endTime)			.. 
	"&location=" 	.. utils.urlEncode(destination.locationName) 
	
	openWebWindow(url, editDestinationListener)

end

-----------------------------------------------------

function editDestinationListener( event )
	
	if string.find(string.lower(event.url), "destinationedited") then
		
		webView:removeEventListener( "urlRequest", editDestinationListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Trip", "destinationEditionCancelled") 
		else
      	analytics.event("Trip", "editDestination")

			if(params["startTime"] 		~= "null") then GLOBALS.selectedJourney.startTime 			= params["startTime"] 		end
			if(params["endTime"] 		~= "null") then GLOBALS.selectedJourney.endTime 			= params["endTime"] 			end
			if(params["locationName"]	~= "null" and params["locationName"] 	~= "same") then GLOBALS.selectedJourney.locationName 		= params["locationName"] 	end
			if(params["locationLat"] 	~= "null" and params["locationLat"]		~= "same") then GLOBALS.selectedJourney.locationLat 		= params["locationLat"]  	end
			if(params["locationLon"] 	~= "null" and params["locationLon"] 	~= "same") then GLOBALS.selectedJourney.locationLon 		= params["locationLon"]		end

      	editDestination()
		end
		
		closeWebWindow(false)
	end

end

-----------------------------------------------------
--

function editDestination()
	
	utils.postWithJSON({
		journey = GLOBALS.selectedJourney
	},
	
	SERVER_URL .. "/editJourney", 
	destinationEdited)
	
end

function destinationEdited( event )
	GLOBALS.selectedJourney = json.decode(event.response)
   afterDestinationEdition()
end
