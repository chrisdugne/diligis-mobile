-----------------------------------------------------------------------------------------
--
-- WriteMessage.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local textBox, charLeftText

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
function scene:refreshScene(event)
	viewManager.setupView(self.view, back);
	self:buildWriter(event);
end
	
-----------------------------------------------------------------------------------------

function scene:buildWriter(event)
	
	local backButton = widget.newButton	{
		width = display.contentWidth/3,
		height = 46,
		label = "Back", 
		labelYOffset = - 1,
		onRelease = back
	}
	
	backButton.x = display.contentCenterX - 70
	backButton.y = display.contentHeight - backButton.contentHeight
	
	self.view:insert( backButton )

	local sendButton = widget.newButton	{
		width = display.contentWidth/3,
		height = 46,
		label = "Send", 
		labelYOffset = - 1,
		onRelease = sendMessage
	}
	
	sendButton.x = display.contentCenterX + 70
	sendButton.y = display.contentHeight - sendButton.contentHeight
	
	self.view:insert( sendButton )

	----------------------

	--- note : a message is always an answer. Answer to another message, or answer to a diligis...
	if not textBox then
      textBox = native.newTextBox( 25, - display.contentHeight, display.contentWidth-50, 220 )
   	textBox.font = native.newFont( native.systemFont, 14 )
      textBox.text = "Hello " .. event.sender.name .. " !\n Perhaps we could meet each other during this trip ?\n\t" .. accountManager.user.name
   	textBox.isEditable = true
      textBox:addEventListener( "userInput", inputListener )
	end

	transition.to( textBox, { y = 60 + textBox.contentHeight/2, time = 400, transition = easing.outExpo } )
   native.setKeyboardFocus( textBox )
	
	----------------------

	charLeftText = display.newText( "(" .. 200-#textBox.text .. ")", display.contentWidth - 60, 300, native.systemFontBold, 14 )
	charLeftText:setTextColor( 0 )
	
	self.view:insert( charLeftText )
end

----------------------

function back() 
	transition.to( textBox, { y = - display.contentHeight, time = 400, transition = easing.inExpo } )
	router.openTrips() 
end
	
function inputListener( event )
	if event.phase == "began" then
	elseif event.phase == "ended" then
	elseif event.phase == "editing" then

		if(#event.text > 200) then
			textBox.text = string.sub(event.text, 1, event.startPosition-1) .. string.sub(event.text, event.startPosition+1) 
		end
		
		charLeftText.text = "(" .. 200-#textBox.text .. ")"

	end
end

function sendMessage()

--	selectedTraveler = {}
--	selectedTraveler.linkedinUID 	= linkedinUID
--	selectedTraveler.name 			= name
--	selectedTraveler.profile 		= profile
-- diligis.travelerLinkedinUID, diligis.travelerName, diligis.travelerProfile

	print("------")
	print("sending message to " .. selectedEvent.travelerLinkedinUID)
	print(textBox.text)
	print("contentUID : " .. selectedEvent.content.uid)
	print("tripFromId : " .. selectedTrip.tripitId)
	
	eventManager.sendMessage(textBox.text, selectedEvent.content.uid, selectedTrip.tripitId)
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene(event.params.event);
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