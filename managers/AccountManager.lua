-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

user = {}

-----------------------------------------------------------------------------------------

function saveUserAndGetAccount()
	utils.postWithJSON({
		user = user;
	},
	SERVER_URL .. "/saveUser", 
	accountReceived)
end

function accountReceived( event )
	user = utils.joinTables(user, json.decode(event.response))
	removeDummyTripAndGetMessages(user)
  	router.openStream()	
end

-----------------------------------------------------------------------------------------

local afterHavingReceivedUser
function refreshUser(next)
	native.setActivityIndicator( true )
	afterHavingReceivedUser = next
	utils.postWithJSON({
		userUID = user.uid;
	},
	SERVER_URL .. "/getUser", 
	receivedUser)
end

function receivedUser( event )
	user = utils.joinTables(user, json.decode(event.response))
	removeDummyTripAndGetMessages(user)
	native.setActivityIndicator( false )
	afterHavingReceivedUser ( user ) 
end

------------------------------------------
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
	removeDummyTrip(user)
	
	native.setActivityIndicator( false )
	return router.displayTrips() 
end

------------------------------------------
--- after a message sent, refresh the journeys from the server to get events
function refreshJourneysFromServer()
	utils.postWithJSON({
		user = user,
	},
	SERVER_URL .. "/getTrips",
	receivedJourneys)
end

function receivedJourneys( event )
	user.trips = json.decode(event.response);
	removeDummyTrip(user)
	
	native.setActivityIndicator( false )
	return router.displayJourneys() 
end

------------------------------------------

function removeDummyTripAndGetMessages(user)

	local dummyTripIndex
	user.messages = {}
	
	if(user.trips) then
		for i in pairs(user.trips) do
   		
      	if(user.trips[i].journeys) then
      		for j in pairs(user.trips[i].journeys) do
      			if(user.trips[i].journeys[j].events) then
            		for m in pairs(user.trips[i].journeys[j].events) do
            			if(user.trips[i].journeys[j].events[m].content.type == eventManager.MESSAGE) then
                     	table.insert(user.messages, user.trips[i].journeys[j].events[m])
            			end
            		end
      			end
      		end
   		end

			if(user.trips[i].tripId == user.uid) then
      		dummyTripIndex = i
			end
		end
		
	   table.remove(user.trips, dummyTripIndex) -- user dummy trip
	end
end

function removeDummyTrip(user)
	if(user.trips) then
		for i in pairs(user.trips) do
			if(user.trips[i].tripId == user.uid) then
   			table.remove(user.trips, i) -- user dummy trip
   			break
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
	connectionFromAppHome = fromAppHome

   linkedIn.authorise(linkedInConnected, linkedInCancel);
end

function linkedInCancel()
	analytics.event("LinkedIn", "linkedInCancel") 
	logout()
end

function linkedInConnected()

	analytics.event("LinkedIn", "linkedInConnected")
	
	user.linkedinUID 	= linkedIn.data.profile.id
	user.firstName 	= linkedIn.data.profile.firstName
	user.lastName 		= linkedIn.data.profile.lastName
	user.name 			= linkedIn.data.profile.firstName .. " " .. linkedIn.data.profile.lastName
	user.headline 		= linkedIn.data.profile.headline
	user.industry 		= linkedIn.data.profile.industry
	user.pictureUrl 	= linkedIn.data.profile.pictureUrl
	user.oldEmail 		= user.email
	user.email 			= linkedIn.data.profile.emailAddress

	saveUserAndGetAccount()
	user.isConnected = true
	
-- DEPRECATED : signup form
--	localData.user 	= user
--	removeDummyTripAndGetMessages(user)
--	localData.linkedin.accessToken 			= linkedIn.data.accessToken
--	localData.linkedin.accessTokenSecret 	= linkedIn.data.accessTokenSecret
end

-----------------------------------------------------------------------------------------

function logout()

	if(accountManager.user.isConnected) then
   	accountManager.user.isConnected = false
		linkedIn.deauthorise()
	end

	router.openAppHome()

end

-----------------------------------------------------------------------------------------
--- V1 : DEPRECATED : signup form
-----------------------------------------------------------------------------------------

--function newUser()
--	print("--------------------- > DEPRECATED : NEW USER @@")
--	return

--	native.setActivityIndicator( true )
--	localData.user.name 			= localData.user.firstName .. " " .. localData.user.lastName
--	localData.user.linkedinUID 	= "none"
--	localData.user.industry 	= "none"
--	localData.user.pictureUrl  = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
--
--	utils.postWithJSON({
--		user = localData.user;
--	},
--	SERVER_URL .. "/getAccount", 
--	newUserListener)
--end

--function newUserListener( event )
--	user = utils.joinTables(user, json.decode(event.response))
--	saveLocalData()
--	
--	native.setActivityIndicator( false )
--	router.displayProfile(accountManager.user.linkedinUID, accountManager.user.uid)
----	eventManager.getStream();
--end

-----------------------------------------------------------------------------------------

--function saveLocalData()
-- DEPRECATED : with diligis signup
--	localData.user = user
--   utils.saveTable(localData, "localData.json")  
--end

-----------------------------------------------------------------------------------------

--function getAccount()
--	utils.postWithJSON({
--		user = user;
--	},
--	SERVER_URL .. "/getAccount", 
--	getAccountListener)
--end
--
--function getAccountListener( event )
--	user = utils.joinTables(user, json.decode(event.response))
--	removeDummyTripAndGetMessages(user)
--	
----	eventManager.getStream();
--	router.displayProfile(accountManager.user.linkedinUID, accountManager.user.uid)
--end

-----------------------------------------------------------------------------------------
--- V1 : DEPRECATED : Tripit
-----------------------------------------------------------------------------------------

--function getTripitProfileAndTrips()
--	tripit.getTripitProfile(verifyTripitProfile)
--end
--
--function syncTripsWithTripit()
--	tripit.getTrips(refreshTrips)
--end

-----------------------------------------------------------------------------------------
--
----
--function verifyTripitProfile()
--
--	native.setActivityIndicator( true )
--	
--	utils.postWithJSON({
--		user 				= user,
--		tripitProfile 	= tripit.data.profile;
--	},
--	SERVER_URL .. "/verifyTripitProfile", 
--	verifyTripitListener)
--end
--
--function verifyTripitListener( event )
--
--	if(event.response == "ok") then
-- 		syncTripsWithTripit()
--	elseif(event.response == "exist") then
--		wrongTripit("Wrong Diligis account", "We have found another Diligis account linked with this Tripit account. Try another Tripit account or Login with your other Diligis account.")
--	else
--		wrongTripit("Wrong Tripit account", "You have linked another tripit account : " .. event.response)
--	end
--	
--end
--
--
--function wrongTripit(title, message)
--	native.showAlert(title, message)
--	native.setActivityIndicator( false )
--	tripit.logout();
--end

-----------------------------------------------------------------------------------------

--function refreshTrips()
--	local trips = {}
--	
--	native.setActivityIndicator( true )
--	if(tripit.data.trips ~= nil) then
--		for i in pairs(tripit.data.trips) do
--			local trip = {
--				displayName	 	= tripit.data.trips[i].display_name.value,
--				id 				= tripit.data.trips[i].id.value,
--				startDate 		= tripit.data.trips[i].start_date.value,
--				endDate 			= tripit.data.trips[i].end_date.value,
--				country		 	= tripit.data.trips[i].PrimaryLocationAddress.country.value,
--				city 				= tripit.data.trips[i].PrimaryLocationAddress.city.value,
--				address 			= tripit.data.trips[i].PrimaryLocationAddress.address.value,
--				latitude 		= tripit.data.trips[i].PrimaryLocationAddress.latitude.value,
--				longitude 		= tripit.data.trips[i].PrimaryLocationAddress.longitude.value,
--				imageUrl 		= tripit.data.trips[i].image_url.value,
--				lastModified 	= tripit.data.trips[i].last_modified.value
--			}
--	
--			table.insert(trips, trip)
--		end
--	end
--
--	user.trips = trips
--	refreshTripsOnServer()
--end

-----------------------------------------------------------------------------------------
--
--

--- after a call to tripit, refresh data on the server
--function refreshTripsOnServer()
--	utils.postWithJSON({
--		user = user,
--	},
--	SERVER_URL .. "/refreshTrips", 
--	receivedTrips)
--end