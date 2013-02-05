-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------
--
--
function getAccount()

	local serverUrl = SERVER_URL .. "/getAccount"

	local postData = 
	{
		user = {
			linkedinId = linkedIn.data.profile.id,
			email = linkedIn.data.profile.emailAddress,
			name = linkedIn.data.profile.firstName .. " " .. linkedIn.data.profile.lastName,
			headline = linkedIn.data.profile.headline,
			industry = linkedIn.data.profile.industry
		}
	}

	local headers = {}
	headers["Content-Type"] = "application/json"

	local params = {}
	params.headers = headers
	params.body = json.encode(postData)

	network.request(serverUrl, "POST", getAccountListener, params)
end

function getAccountListener( event )
	print(event.response);
end




