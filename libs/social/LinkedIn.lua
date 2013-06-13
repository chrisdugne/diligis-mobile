-----------------------------------------------------------------------------------------
-- Project: LinkedIn for Corona
--
-- Date: January 28, 2013
--
-- Version: 1.3
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
function init(consumerKey, consumerSecret, previousAccessToken, previousAccessTokenSecret)
	
	data.consumerKey = consumerKey
	data.consumerSecret = consumerSecret

	data.accessToken 			= previousAccessToken
	data.accessTokenSecret 	= previousAccessTokenSecret

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
		webView:addEventListener( "urlRequest", webviewListener )
		webView:request( authenticateUrl )
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

			if(webView) then
				webView:removeSelf()
				webView = nil;
			end
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
	else
		local details = ""
		if(event.errorMessage) then 
			details = event.errorMessage
		end
		
		native.showAlert( "Linkedin connection problem..", "Please try another account. Details : " .. details, { "OK" } )
		deauthorise()
	end

end

-----------------------------------------------------------------------------------------
--- Data pulling
--- Require all data we want with the [accessToken + accessTokenSecret]
-----------------------------------------------------------------------------------------

--- profile request
function getProfile()

--	local profileUrl = "http://api.linkedin.com/v1/people/~"
	local profileUrl = "http://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-url,headline,industry,email-address,public-profile-url)"

	local customParams = 
	{
		format = "json"
	}
	
	oAuth.networkRequest(profileUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", profileListener)
end

--- profile reception
function profileListener( event )

	local response = json.decode(event.response)
	
	if ( response.errorCode ) then
		native.showAlert( "Linkedin Error", response.message, { "OK" } )
		deauthorise()
	else
		data.profile = response

		if( not data.profile.emailAddress) then
			data.profile.emailAddress = ""
		end

		if( not data.profile.firstName) then
			data.profile.firstName = ""
		end

		if( not data.profile.lastName) then
			data.profile.lastName = ""
		end
		
      if(not data.profile.pictureUrl) then
      	data.profile.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
      end
      
   	callBackAuthorisationDone();
	end

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

	if(#ids == 0) then
		next()
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
	
   analytics.event("LinkedIn", "getPeopleProfile") 
   	
	if(data.people[id] ~= nil) then
		next()
	else
   	peopleProfileReceived = next;
   	
   	local profileUrl = "http://api.linkedin.com/v1/people/id=".. id ..":(id,first-name,last-name,picture-url,headline,industry,email-address,site-standard-profile-request)";
   	local customParams = {
   		format = "json",
   		linkedinUID = id
   	}
   
   	oAuth.networkRequest(profileUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", peopleProfileListener)
   end

end

--- profile reception
function peopleProfileListener( event )
	
	if ( not event.isError ) then
   	
		local profile = json.decode(event.response)
		
		if(profile.id == "private") then
      	local params = utils.getUrlParams(event.url)
			profile.id = params.linkedinUID
			profile.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
		end
		
      if(not profile.pictureUrl) then
      	profile.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
      end

		data.people[profile.id] = profile
		utils.print(data.people)
	end

	peopleProfileReceived();

end

-----------------------------------------------------------------------------------------
--- Deauthorises the user.
-----------------------------------------------------------------------------------------

function deauthorise()
	local logoutURL = "https://api.linkedin.com/uas/oauth/invalidateToken";
	local customParams = {}
	 
	print("deauthorise")
	print(data.consumerKey)
	print(data.accessToken)
	print(data.consumerSecret)
	print(data.accessTokenSecret)
	
	oAuth.networkRequest(logoutURL, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", logoutListener)
end

--- logout ok
function logoutListener( event )

	data.accessToken = nil
	data.accessTokenSecret = nil
	data.profile = nil
	
	if(callBackCancel) then
		callBackCancel()
	end
end

--