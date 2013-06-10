-----------------------------------------------------------------------------------------
--
-- WriteMessage.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local textBox, charLeftText
local selectedEvent
local back

----------------------

function effectBack()
 	native.setKeyboardFocus( nil ) 
	transition.to( textBox, { y = - display.contentHeight, time = 400, transition = easing.inExpo, onComplete = back } )
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
	viewManager.setupView(self.view, effectBack);
	self:buildWriter(event);
end
	
-----------------------------------------------------------------------------------------

function scene:buildWriter(event)
	
	selectedEvent = event
	print("buildWriter")
	utils.tprint(selectedEvent)
	
	local backButton = widget.newButton	{
		width = display.contentWidth/6,
		height = 23,
		label = "Back", 
		labelYOffset = 2,
		onRelease = effectBack
	}
	
	backButton.x = display.contentCenterX - 70
	backButton.y = 40 + backButton.contentHeight
	
	self.view:insert( backButton )

	local sendButton = widget.newButton	{
		width = display.contentWidth/6,
		height = 23,
		label = "Send", 
		labelYOffset = 2,
		onRelease = sendMessage
	}
	
	sendButton.x = display.contentCenterX + 70
	sendButton.y = 40 + sendButton.contentHeight
	
	self.view:insert( sendButton )

	----------------------

	--- note : a message is always an answer. Answer to another message, or answer to a diligis...
--	if not textBox then
      textBox = native.newTextBox( 25, - display.contentHeight, display.contentWidth-50, 220 )
   	textBox.font = native.newFont( native.systemFont, 14 )
   	textBox.isEditable = true
      textBox:addEventListener( "userInput", inputListener )
--	end

	----------------------

	textBox.text = ""   

	----------------------

	transition.to( textBox, { y = 140 + textBox.contentHeight/2, time = 400, transition = easing.outExpo } )
   native.setKeyboardFocus( textBox )
	
	----------------------

	charLeftText = display.newText( "(" .. 200-#textBox.text .. ")", display.contentWidth - 60, 100, native.systemFontBold, 14 )
	charLeftText:setTextColor( 0 )
	
	self.view:insert( charLeftText )
	
	----------------------

	local writingToText = display.newText( "to " .. selectedEvent.sender.name, 40, 300, native.systemFontBold, 14 )
	writingToText:setTextColor( 0 )
	
	self.view:insert( writingToText )
end

----------------------

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
	
   analytics.event("Message", "sendMessage") 
   
	-- BUG with copy paste we may go over 200 :s
	if(#textBox.text < 201) then
	
		if(isAnswer) then 

			local tripId
			if(selectedEvent.recepient) then
				tripId = selectedEvent.recepient.tripId
   		else
   			tripId = selectedTrip.tripitId
   		end

			eventManager.sendAnswer(textBox.text, selectedEvent.content.uid, tripId)
   		
   	else
   		eventManager.sendMessage(textBox.text, accountManager.user.email, selectedEvent.sender.tripId)
		end
		
   	effectBack()
	end
	
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