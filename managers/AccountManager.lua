-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

user = {}

-----------------------------------------------------------------------------------------

function getAccount()
	utils.postWithJSON({
		user = user;
	},
	SERVER_URL .. "/getAccount", 
	getAccountListener)
end

function getAccountListener( event )
	user = json.decode(event.response);
	removeDummyTripAndGetMessages()
	
	eventManager.getStream();
end

-----------------------------------------------------------------------------------------

function getTripitProfileAndTrips()
	tripit.getTripitProfile(verifyTripitProfile)
end

function syncTripsWithTripit()
	tripit.getTrips(refreshTrips)
end

-----------------------------------------------------------------------------------------
--
--
function verifyTripitProfile()

	native.setActivityIndicator( true )
	
	utils.postWithJSON({
		user 				= user,
		tripitProfile 	= tripit.data.profile;
	},
	SERVER_URL .. "/verifyTripitProfile", 
	verifyTripitListener)
end

function verifyTripitListener( event )

	if(event.response == "ok") then
 		syncTripsWithTripit()
	elseif(event.response == "exist") then
		wrongTripit("Wrong Diligis account", "We have found another Diligis account linked with this Tripit account. Try another Tripit account or Login with your other Diligis account.")
	else
		wrongTripit("Wrong Tripit account", "You have linked another tripit account : " .. event.response)
	end
	
end


function wrongTripit(title, message)
	native.showAlert(title, message)
	native.setActivityIndicator( false )
	tripit.logout();
end

-----------------------------------------------------------------------------------------

function refreshTrips()
	local trips = {}
	
	native.setActivityIndicator( true )
	if(tripit.data.trips ~= nil) then
		for i in pairs(tripit.data.trips) do
			local trip = {
				displayName	 	= tripit.data.trips[i].display_name.value,
				id 				= tripit.data.trips[i].id.value,
				startDate 		= tripit.data.trips[i].start_date.value,
				endDate 			= tripit.data.trips[i].end_date.value,
				country		 	= tripit.data.trips[i].PrimaryLocationAddress.country.value,
				city 				= tripit.data.trips[i].PrimaryLocationAddress.city.value,
				address 			= tripit.data.trips[i].PrimaryLocationAddress.address.value,
				latitude 		= tripit.data.trips[i].PrimaryLocationAddress.latitude.value,
				longitude 		= tripit.data.trips[i].PrimaryLocationAddress.longitude.value,
				imageUrl 		= tripit.data.trips[i].image_url.value,
				lastModified 	= tripit.data.trips[i].last_modified.value
			}
	
			table.insert(trips, trip)
		end
	end

	user.trips = trips
	refreshTripsOnServer()
end

-----------------------------------------------------------------------------------------
--
--

--- after a call to tripit, refresh data on the server
function refreshTripsOnServer()
	utils.postWithJSON({
		user = user,
	},
	SERVER_URL .. "/refreshTrips", 
	receivedTrips)
end

--- after a message sent, refresh the trips from the server to get events
function refreshTripsFromServer()
	utils.postWithJSON({
		user = user,
	},
	SERVER_URL .. "/getTrips",
	receivedTrips)
end

function receivedTrips( event )
	user.trips = json.decode(event.response);
	removeDummyTripAndGetMessages()
	
	native.setActivityIndicator( false )
	return router.displayTrips() 
end

------------------------------------------

function removeDummyTripAndGetMessages()

	user.messages = {}
	
	if(user.trips) then
		for i in pairs(user.trips) do
   		
      	if(user.trips[i].events) then
      		for m in pairs(user.trips[i].events) do
      			if(user.trips[i].events[m].content.type == eventManager.MESSAGE) then
               	table.insert(user.messages, user.trips[i].events[m])
      			end
      		end
   		end

			if(user.trips[i].tripitId == user.uid) then
      		table.remove(user.trips, i) -- user dummy trip
			end
		end
	end
end

------------------------------------------

function readEvent(event)
	utils.postWithJSON({
		event = event;
	},
	SERVER_URL .. "/readEvent")
end

------------------------------------------
--- LinkedIn
-- 

function linkedInConnect()
	linkedIn.init(LINKEDIN_CONSUMER_KEY, LINKEDIN_CONSUMER_SECRET);
	linkedIn.authorise(linkedInConnected, linkedInCancel);
end

function linkedInCancel()
	analytics.event("LinkedIn", "linkedInCancel") 
	router.openAppHome()
end

function linkedInConnected()

	analytics.event("LinkedIn", "linkedInConnected") 

	user =	{
		linkedinId 		= linkedIn.data.profile.id,
		email 			= linkedIn.data.profile.emailAddress,
		name 				= linkedIn.data.profile.firstName .. " " .. linkedIn.data.profile.lastName,
		headline 		= linkedIn.data.profile.headline,
		industry 		= linkedIn.data.profile.industry
	}

	getAccount()
end

-----------------------------------------------------------------------------------------
--

function logout()
	linkedIn.deauthorise()
	tripit.logout()
	router.openAppHome()
end
