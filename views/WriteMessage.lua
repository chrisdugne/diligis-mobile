-----------------------------------------------------------------------------------------
--
-- WriteMessage.lua
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local back

-----------------------------------------------------------------------------------------

function openWebWindow(url, listener)
	webView = native.newWebView( display.screenOriginX, display.screenOriginY + HEADER_HEIGHT + 100, display.contentWidth, display.contentHeight - HEADER_HEIGHT - 100)
	webView:addEventListener( "urlRequest", listener )
	webView:request( url )

	isWebViewOpened = true
end

function closeWebWindow(goBack)
	if(webView) then
		webView:removeSelf()
		webView = nil
		isWebViewOpened = false
	end
	
	if(goBack) then
		back()
	end
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )

end
	
-----------------------------------------------------------------------------------------

--- here 'event' is a Diligis Event + content + sender
function scene:refreshScene(event, answer, fromView)
	back = fromView
	isAnswer = answer
	viewManager.setupView(self.view, back);
	self:buildWriter(event);
end
	
-----------------------------------------------------------------------------------------

function scene:buildWriter(event)
	
	GLOBALS.selectedEvent = event
	
	--- get all linkedin profiles
	local ids = {}
	if type(event.sender) ~= "table" then event.sender = json.decode(event.sender) end
	if event.recepient and type(event.recepient) ~= "table" then event.recepient = json.decode(events.recepient) end
		
	if(event.sender.linkedinUID ~= "none") then
		table.insert(ids, event.sender.linkedinUID)
	end

	if(event.recepient and event.recepient.linkedinUID ~= "none") then
		table.insert(ids, event.recepient.linkedinUID)
	end

	if(accountManager.user.isConnected) then
		linkedIn.getProfiles(ids, function(event) return self:drawWriteTo() end)
	else 
		self:drawWriteTo()
	end
end
	

function scene:drawWriteTo()

   local text = display.newText( "Write a message to ", 20, 60, native.systemFont, 12 )
   text:setTextColor( 0 )
   self.view:insert(text)

	local pictureUrl = linkedIn.data.people[GLOBALS.selectedEvent.sender.linkedinUID].pictureUrl
   local text = display.newText( GLOBALS.selectedEvent.sender.name .. " :", 20, 77, native.systemFont, 12 )
	text:setTextColor( 0 )
	self.view:insert(text)
		
	imagesManager.drawImage(
		self.view, 
		pictureUrl, 
		display.contentWidth - 50 , 90,
		IMAGE_CENTER, 1,
		false,
		function(picture) return self:displayWebView(picture) end
	)
end

function scene:displayWebView()
	local url = SERVER_URL .. "/writeMessage" 
	openWebWindow(url, writeListener)
end
	
function writeListener( event )

	if string.find(string.lower(event.url), "messagewriten") then
		
		webView:removeEventListener( "urlRequest", writeListener )
		
		local params = utils.getUrlParams(event.url);
		
		if(params.cancel == '1') then
      	analytics.event("Message", "cancelSendMessage") 
   		closeWebWindow(true)
		else
      	analytics.event("Message", "sendMessage")
      	sendMessage(params.message)
   		closeWebWindow()
		end
		
	end

end

----------------------

function sendMessage(message)

	if(isAnswer) then 
		local journeyId
		if(GLOBALS.selectedEvent.recepient) then
			journeyId = GLOBALS.selectedEvent.recepient.journeyId
		else
			journeyId = GLOBALS.selectedJourney.journeyId
		end

		eventManager.sendAnswer(message, GLOBALS.selectedEvent.content.uid, journeyId)
		
	else
		eventManager.sendMessage(message, accountManager.user.email, GLOBALS.selectedEvent.sender.journeyId)
	end
	
	back()
	
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene(event.params.event, event.params.answer, event.params.back);
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )

end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene