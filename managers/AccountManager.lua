-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

user = {}

-----------------------------------------------------------------------------------------
--
--
function getAccount()
	router.callServer({
		user = user;
	},
	"getAccount", 
	getAccountListener)
end

function getAccountListener( event )
	user = json.decode(event.response);
	eventManager.getStream();
end

-----------------------------------------------------------------------------------------
--
--
function verifyTripitProfile()
	router.callServer({
		user 			= user,
		tripitProfile 	= tripit.data.profile;
	},
	"verifyTripitProfile", 
	verifyTripitListener)
end

function verifyTripitListener( event )

	if(event.response == "ok") then
		refreshTrips()
	elseif(event.response == "exist") then
		wrongTripit("Wrong Diligis account", "We have found another Diligis account linked with this Tripit account. Try another Tripit account or Login with your other Diligis account.")
	else
		wrongTripit("Wrong Tripit account", "You have linked another tripit account : " .. event.response)
	end
	
end


function wrongTripit(title, message)
	native.showAlert(title, message)
	tripit.logout();
end

function refreshTrips()
	local trips = {}
	
	if(tripit.data.trips ~= nil) then
		for i in pairs(tripit.data.trips) do
			local trip = {
				displayName	 	= tripit.data.trips[i].display_name.value,
				id 				= tripit.data.trips[i].id.value,
				startDate 		= tripit.data.trips[i].start_date.value,
				endDate 		= tripit.data.trips[i].end_date.value,
				country		 	= tripit.data.trips[i].PrimaryLocationAddress.country.value,
				city 			= tripit.data.trips[i].PrimaryLocationAddress.city.value,
				address 		= tripit.data.trips[i].PrimaryLocationAddress.address.value,
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
function refreshTripsOnServer()
	router.callServer({
		user = user,
	},
	"refreshTrips", 
	function() return router.openTrips() end)
end

