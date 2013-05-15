-----------------------------------------------------------------------------------------
-- Project: Tripit for Corona
--
-- Date: February 02, 2013
--
-- Version: 1.0
--
-- File name: Tripit.lua
--
-- Author: Chris Dugne @ Uralys - www.uralys.com
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
local callBackCancel;

----------------------------------------------------------------------------------------------------

--- Initiates a new tripit object.
-- @param consumerKey The consumer key of your app.
-- @param consumerSecret The consumer secret of your app.
function init()

	data.consumerKey = "02230a62bdc05aa23da53c683b78427a644b7459";
	data.consumerSecret = "03e8b2b77d80fdaca283d33c15805d97bcc82efd"

	data.requestToken = nil
	data.requestTokenSecret = nil

	data.accessToken = nil
	data.accessTokenSecret = nil

	data.profile = {}

end

-----------------------------------------------------------------------------------------
-- Authorises the user.
-----------------------------------------------------------------------------------------
--

--- 1 - Request a requestToken
function authorise(callBack, cancel)
	native.setActivityIndicator( true )
	callBackAuthorisationDone = callBack;
	callBackCancel = cancel;
	getRequestToken();
end

function getRequestToken()
	print("getRequestToken")
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

		native.setActivityIndicator( false )
		webView = native.newWebView( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight)
		webView:request( authenticateUrl )

		webView:addEventListener( "urlRequest", webviewListener )
	end
end

-----------------------------------------------------
--

--- 2 - Authorisation via LinkedIn Popup in the webView
function webviewListener( event )

	print(event.url)

	if event.url then
		if (string.lower(event.url) == "https://m.tripit.com/") then
      	webView:removeSelf()
      	webView = nil;
		elseif string.find(string.lower(event.url), "https://m.tripit.com/oauth/backtodiligis") then
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

	native.setActivityIndicator( true )
	
	local accessTokenUrl = "https://api.tripit.com/oauth/access_token"
	local customParams = {} 

	oAuth.networkRequest(accessTokenUrl, customParams, data.consumerKey, data.requestToken, data.consumerSecret, data.requestTokenSecret, "POST", accessTokenListener)

end


--- accessToken reception
function accessTokenListener( event )

	if ( not event.isError ) then
		data.accessToken = event.response:match('oauth_token=([^&]+)')
		data.accessTokenSecret = event.response:match('oauth_token_secret=([^&]+)')

		callBackAuthorisationDone();
	end
	
	native.setActivityIndicator( false )
end

-----------------------------------------------------------------------------------------
--- tripit pulling
--- Require all tripit we want with the [accessToken + accessTokenSecret]
-----------------------------------------------------------------------------------------

local afterProfile

--- profile request
function getTripitProfile(next)
	
	afterProfile = next

	local profileUrl = "https://api.tripit.com/v1/get/profile"
	local customParams = {} 

	oAuth.networkRequest(profileUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", tripitProfileListener)
end

--- reception
function tripitProfileListener( event )
	if ( not event.isError ) then
		local response = xml.parseXML(event.response).Response

		if(response.Error ~= nil) then
			native.showAlert("Connection impossible", response.Error.description.value)
			callBackCancel();
			native.setActivityIndicator( false )
		else
			data.profile.ref = response.Profile.ref
			
			if(table.getn(response.Profile.ProfileEmailAddresses.ProfileEmailAddress) > 0) then
				data.profile.email = response.Profile.ProfileEmailAddresses.ProfileEmailAddress[1].address.value;
			else
				data.profile.email = response.Profile.ProfileEmailAddresses.ProfileEmailAddress.address.value;
			end
			
      	if(afterProfile ~= nil) then
      		afterProfile()
			end
		end
	end
end

-----------------------------------------------------------------------------------------

local afterTrips

--- trips to come
function getTrips(next)
	
	afterTrips = next

	local tripsUrl = "https://api.tripit.com/v1/list/trip"
	local customParams = {} 

	oAuth.networkRequest(tripsUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", tripsListener)
end

--- reception
function tripsListener( event )

	if ( not event.isError ) then
		local response = xml.parseXML(event.response).Response
		data.trips = xml.asTable(response.Trip)
		
		getPastTrips()
	end
	
end

--- past trips
function getPastTrips()
	local tripsUrl = "https://api.tripit.com/v1/list/trip/past/true"
	local customParams = {} 

	oAuth.networkRequest(tripsUrl, customParams, data.consumerKey, data.accessToken, data.consumerSecret, data.accessTokenSecret, "GET", pastTripsListener)
end

--- reception
function pastTripsListener( event )

	if ( not event.isError ) then
		local response = xml.parseXML(event.response).Response
		utils.joinTables(data.trips, xml.asTable(response.Trip))
	end
	
   if(afterTrips ~= nil) then
   	afterTrips()
   end
		
	native.setActivityIndicator( false )
end

function logout()
	local logoutUrl = "https://m.tripit.com/account/logout"
	network.request(logoutUrl, "GET")
end

-----------------------------------------------------------------------------------------
--- Tripit : create a Trip !
-- 
-- 
-- 
local afterCreateTrip 

--- requestToken reception
function openNewTripWindow(next)

	afterCreateTrip = next

	local createTripUrl = "https://m.tripit.com/trip/create"

	webView = native.newWebView( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight)
	webView:request( createTripUrl )

	webView:addEventListener( "urlRequest", createTripListener )
end

-----------------------------------------------------
--

--- 2 - Authorisation via LinkedIn Popup in the webView
function createTripListener( event )

	print("createTripListener : " .. event.url)
	
	if event.url == "https://m.tripit.com/home" 
	or string.find(string.lower(event.url), "https://m.tripit.com/trip/show/id/") 
	then
	
      if(afterCreateTrip ~= nil) then
      	afterCreateTrip()
      end
		
		webView:removeSelf()
		webView = nil;
	end

end