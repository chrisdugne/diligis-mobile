-----------------------------------------------------------------------------------------
-- Project: Tripit for Corona
--
-- Date: February 02, 2013
--
-- Version: 1.0
--
-- File name: Tripit.lua
--
-- Author: Chris Dugne of Uralys - www.uralys.com
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

----------------------------------------------------------------------------------------------------

data = {}

----------------------------------------------------------------------------------------------------

local oAuth = require( "libs.oauth.oAuth" )

----------------------------------------------------------------------------------------------------

local webView;
local callBackAuthorisationDone;

----------------------------------------------------------------------------------------------------

--- Initiates a new data object.
-- @param consumerKey The consumer key of your app.
-- @param consumerSecret The consumer secret of your app.
function init()

	data.consumerKey = "02230a62bdc05aa23da53c683b78427a644b7459";
	data.consumerSecret = "03e8b2b77d80fdaca283d33c15805d97bcc82efd"

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
function authorise(callBack)
	callBackAuthorisationDone = callBack;
	getRequestToken();
end

function getRequestToken()

	local requestTokenUrl = "https://api.tripit.com/oauth/request_token"
	local customParams = {}

	oAuth.networkRequest(requestTokenUrl, customParams, data.consumerKey, nil, data.consumerSecret, nil, "POST", requestTokenListener)

end

--- requestToken reception
function requestTokenListener( event )
	if ( not event.isError ) then

		data.requestToken = event.response:match('oauth_token=([^&]+)')
		data.requestTokenSecret = event.response:match('oauth_token_secret=([^&]+)')

		-- need to add a dummy callBack to go to authListener (else go to the linkedIn OOB page)
		local authenticateUrl = "https://m.tripit.com/oauth/authorize?oauth_token=" .. data.requestToken .."&oauth_callback=backtodiligis"

		webView = native.newWebView( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
--		webView = native.newWebView( 0, 0, 320, 480 )
		webView:request( authenticateUrl )

		webView:addEventListener( "urlRequest", webviewListener )

	end
end

-----------------------------------------------------
--

--- 2 - Authorisation via LinkedIn Popup in the webView
function webviewListener( event )

	if event.url then
		if string.find(string.lower(event.url), "https://m.tripit.com/oauth/backtodiligis") then

			getAccessToken()
		
			webView:removeSelf()
			webView = nil;
		end
	end

	if event.errorCode then
		native.showAlert( "Error!", event.errorMessage, { "OK" } )
	end

end

-----------------------------------------------------

--- 3 - Request the accessToken
function getAccessToken()

	local accessTokenUrl = "https://api.tripit.com/oauth/access_token"
	local customParams = {} 

	oAuth.networkRequest(accessTokenUrl, customParams, data.consumerKey, data.requestToken, data.consumerSecret, data.requestTokenSecret, "POST", accessTokenListener)
        
end


--- accessToken reception
function accessTokenListener( event )

	if ( not event.isError ) then

		data.accessToken = event.response:match('oauth_token=([^&]+)')
		data.accessTokenSecret = event.response:match('oauth_token_secret=([^&]+)')

		getTrips();
		
	end
	
end

-----------------------------------------------------------------------------------------
--- Data pulling
--- Require all data we want with the [accessToken + accessTokenSecret]
-----------------------------------------------------------------------------------------

--- profile request
function getTrips()

	local profileUrl = "https://api.tripit.com/v1/list/trip";
	local customParams = {} 

	oAuth.networkRequest(profileUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", tripsListener)
        
end

--- profile reception
function tripsListener( event )

	if ( not event.isError ) then
	
		local response = xml.parseXML(event.response).Response
		data.trips = response.Trip
		
	end
	
	callBackAuthorisationDone();
	
end
