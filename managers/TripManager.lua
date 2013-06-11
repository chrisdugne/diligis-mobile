-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function createTrip()
	local trip = {
		name 			= "New trip",
		imageUrl 	= "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png",
		journeys 	= {} 
	}
	table.insert(accountManager.user.trips, trip)
end

-----------------------------------------------------------------------------------------

-- 
-- 
local afterCreateTrip 

--- requestToken reception
function openNewJourneyWindow(next)

   analytics.event("Trip", "openJourneyWebView") 
	afterCreateTrip = next

	local url = SERVER_URL .. "/create"

	webView = native.newWebView( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight)
	webView:addEventListener( "urlRequest", createTripListener )
	webView:request( url )

end

-----------------------------------------------------
--

function createTripListener( event )
	print(event.url)
	if string.find(string.lower(event.url), "addjourney") then
	
		local params = utils.getUrlParams(event.url);
		utils.tprint(params)
		if(params.type == 0) then
			print("cancelled")
      	analytics.event("Trips", "creationCancelled") 
		else
			print("adding journey !")
      	analytics.event("Trips", "addJourney") 
		end
		
		webView:removeSelf()
		webView = nil;
	end

end