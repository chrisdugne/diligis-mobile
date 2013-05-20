-----------------------------------------------------------------------------------------
-- Project: LinkedIn for Corona
--
-- Date: January 28, 2013
--
-- Version: 1.2
--
-- File name	: LinkedIn.lua
-- Require 		: Utils.lua
-- 
-- Author: Chris Dugne @ Uralys - www.uralys.com
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

----------------------------------------------------------------------------------------------------

data = {}
data.people = {}

----------------------------------------------------------------------------------------------------

local oAuth = require( "libs.oauth.oAuth" )

----------------------------------------------------------------------------------------------------

local webView;
local callBackAuthorisationDone;
local callBackCancel;

----------------------------------------------------------------------------------------------------

--- Initiates a new data object.
-- @param consumerKey The consumer key of your app.
-- @param consumerSecret The consumer secret of your app.
function init(consumerKey, consumerSecret)
	
	data.consumerKey = consumerKey
	data.consumerSecret = consumerSecret

	data.requestToken = nil
	data.requestTokenSecret = nil

	data.accessToken = nil
	data.accessTokenSecret = nil

	data.profile = nil

end

-----------------------------------------------------------------------------------------
-- Authorises the user.
-----------------------------------------------------------------------------------------
--

--- 1 - Request a requestToken
function authorise(callBack, cancel)
	callBackAuthorisationDone = callBack;
	callBackCancel = cancel;
	getRequestToken();
end

function getRequestToken()

	local requestTokenUrl = "https://api.linkedin.com/uas/oauth/requestToken"

	local customParams = 
	{
		oauth_callback = "appcallback_"..data.consumerKey,
		scope = "r_fullprofile r_emailaddress r_network rw_nus"
	}

	oAuth.networkRequest(requestTokenUrl, customParams, data.consumerKey, nil, data.consumerSecret, nil, "POST", requestTokenListener)

end

--- requestToken reception
function requestTokenListener( event )

	if ( not event.isError ) then

		data.requestToken = event.response:match('oauth_token=([^&]+)')
		data.requestTokenSecret = event.response:match('oauth_token_secret=([^&]+)')

		-- need to add a dummy callBack to go to authListener (else go to the linkedIn OOB page)
		local authenticateUrl = "https://www.linkedin.com/uas/oauth/authenticate?oauth_token=" .. data.requestToken

		webView = native.newWebView( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
		webView:request( authenticateUrl )

		webView:addEventListener( "urlRequest", webviewListener )

	end
end

-----------------------------------------------------
--

--- 2 - Authorisation via LinkedIn Popup in the webView
function webviewListener( event )

	if event.url then
		if string.find(string.lower(event.url), "appcallback_"..data.consumerKey) then
			
			local params = utils.getUrlParams(event.url);
			
			if(params["oauth_problem"] == "user_refused") then
				callBackCancel();
			else
				getAccessToken(params["oauth_verifier"])
			end

			webView:removeSelf()
			webView = nil;
		end
	end

end

-----------------------------------------------------

--- 3 - Request the accessToken
function getAccessToken(oauthVerifier)
	local accessTokenUrl = "https://api.linkedin.com/uas/oauth/accessToken"

	local customParams = 
	{
		oauth_verifier = oauthVerifier
	}

	oAuth.networkRequest(accessTokenUrl, customParams, data.consumerKey, data.requestToken, data.consumerSecret, data.requestTokenSecret, "POST", accessTokenListener)

end


--- accessToken reception
function accessTokenListener( event )

	if ( not event.isError ) then

		data.accessToken = event.response:match('oauth_token=([^&]+)')
		data.accessTokenSecret = event.response:match('oauth_token_secret=([^&]+)')

		getProfile();
		--deauthorise()
	end

end

-----------------------------------------------------------------------------------------
--- Data pulling
--- Require all data we want with the [accessToken + accessTokenSecret]
-----------------------------------------------------------------------------------------

--- profile request
function getProfile()

	local profileUrl = "http://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-url,headline,industry,email-address)";

	local customParams = 
	{
		format = "json"
	}

	oAuth.networkRequest(profileUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", profileListener)

end

--- profile reception
function profileListener( event )

	if ( not event.isError ) then
		data.profile = json.decode(event.response);
	end

	callBackAuthorisationDone();

end

------------------------------------------------------
--
-- Get a list of profiles, then proceed to afterProfilesReceived
	
local nbProfilesReceived
local nbProfilesToGet
local afterProfilesReceived

function getProfiles(ids, next)
	
	afterProfilesReceived = next
	nbProfilesReceived = 0
	nbProfilesToGet = #ids
	
	for i in pairs(ids) do
   	getPeopleProfile(ids[i], profileReceived) 
	end

end

function profileReceived()
	nbProfilesReceived = nbProfilesReceived + 1
	
	if(nbProfilesReceived == nbProfilesToGet
	and afterProfilesReceived ~= nil) 
	then
   	afterProfilesReceived()
	end
end

------------------------------------------------------
--- profile request

local peopleProfileReceived
function getPeopleProfile(id, next)
	
	if(data.people[id] ~= nil) then
		next()
	else
   	peopleProfileReceived = next;
   	
   	local profileUrl = "http://api.linkedin.com/v1/people/id=".. id ..":(id,first-name,last-name,picture-url,headline,industry,email-address)";
   	local customParams = {
   		format = "json"
   	}
   
   	oAuth.networkRequest(profileUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", peopleProfileListener)
   end

end

--- profile reception
function peopleProfileListener( event )

	if ( not event.isError ) then
		local profile = json.decode(event.response)
		data.people[profile.id] = profile
		
		utils.tprint(data.people)
	end

	peopleProfileReceived();

end

-----------------------------------------------------------------------------------------
--- Deauthorises the user.
-----------------------------------------------------------------------------------------

function deauthorise()
	local logoutURL = "https://api.linkedin.com/uas/oauth/invalidateToken";
	local customParams = {}
	 
	oAuth.networkRequest(logoutURL, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", logoutListener)
end

--- logout ok
function logoutListener( event )
	data.accessToken = nil
	data.accessTokenSecret = nil
	data.profile = nil
	callBackCancel()
end

--