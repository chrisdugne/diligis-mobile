-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

user = {}

-----------------------------------------------------------------------------------------
--
--
function getAccount()
	local serverUrl = SERVER_URL .. "/getAccount"

	local postData = 
	{
		user = accountManager.user;
	}

	local headers = {}
	headers["Content-Type"] = "application/json"

	local params = {}
	params.headers = headers
	params.body = json.encode(postData)

	network.request(serverUrl, "POST", getAccountListener, params)
end

function getAccountListener( event )
	accountManager.user = json.decode(event.response);
	router.openHome();
end

-----------------------------------------------------------------------------------------
--
--
function refreshTrips()
	
	local serverUrl = SERVER_URL .. "/refreshTrips"

	local postData = 
	{
		user = accountManager.user;
	}

	local headers = {}
	headers["Content-Type"] = "application/json"

	local params = {}
	params.headers = headers
	params.body = json.encode(postData)

	network.request(serverUrl, "POST", refreshTripsListener, params)
end

function refreshTripsListener( event )
	router.openTrips()
end


