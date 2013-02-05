-----------------------------------------------------------------------------------------
-- Project: LinkedIn for Corona
--
-- Date: January 28, 2013
--
-- Version: 1.0
--
-- File name: LinkedIn.lua
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

	data.consumerKey = "nkdrs359t7ta";
	data.consumerSecret = "cixqyissLNH8fQ44"

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

	local requestTokenUrl = "https://api.linkedin.com/uas/oauth/requestToken"

	local customParams = 
	{
		oauth_callback = "backtodiligis",
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

		-- webView = native.newWebView( display.screenOriginX, display.screenOriginY, fullX, fullY )
		webView = native.newWebView( 0, 0, 320, 480 )
		webView:request( authenticateUrl )

		webView:addEventListener( "urlRequest", webviewListener )

	end
end

-----------------------------------------------------
--

--- 2 - Authorisation via LinkedIn Popup in the webView
function webviewListener( event )

	if event.url then
		if string.find(string.lower(event.url), "backtodiligis") then

			local params = utils.getUrlParams(event.url);
			
			getAccessToken(params["oauth_verifier"])
			
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
		print ( "pictureUrl : " .. data.profile.pictureUrl )
	end
	
	callBackAuthorisationDone();
	
end

-----------------------------------------------------------------------------------------
--- Deauthorises the user.
-----------------------------------------------------------------------------------------

function deauthorise()

	data.accessToken = nil
	data.accessTokenSecret = nil
	data.profile = nil

	-- os.remove( system.pathForFile( "data.dat", system.DocumentsDirectory ) )

end

--