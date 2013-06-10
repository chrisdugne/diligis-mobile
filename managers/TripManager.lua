-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

-- 
-- 
local afterCreateTrip 

--- requestToken reception
function openNewJourneyWindow(next)

   analytics.event("Trip", "createJourney") 
	afterCreateTrip = next

	local url = SERVER_URL .. "/create"

	webView = native.newWebView( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight)
	webView:addEventListener( "urlRequest", createTripListener )
	webView:request( url )

end

-----------------------------------------------------
--

function createTripListener( event )

	if string.lower(event.url) == "https://m.tripit.com/"
	or string.lower(event.url) == "https://m.tripit.com/home"
	then
   	analytics.event("Tripit", "creationCancelled") 
		webView:removeSelf()
		webView = nil;
	end
	
	if string.find(string.lower(event.url), "https://m.tripit.com/trip/show/id/") then
	
      if(afterCreateTrip ~= nil) then
      	afterCreateTrip()
      end
		
   	analytics.event("Tripit", "creationComplete") 
		webView:removeSelf()
		webView = nil;
	end

end