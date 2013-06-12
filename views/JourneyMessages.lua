-----------------------------------------------------------------------------------------
--
-- JourneyMessages.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local list
local events

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

function scene:refreshScene(back)
	viewManager.setupView(self.view);
	viewManager.addCustomButton("images/buttons/leftArrow.png", back);
--	viewManager.addCustomButton("images/icons/messages.icon.png", self.openWriter);
	self:buildMessages();
end
	
-----------------------------------------------------------------------------------------

function scene:buildMessages()

	native.setActivityIndicator( true )
	
	----------------------

	list = widget.newTableView{
		top 				= 38,
		width 			= 320, 
		height			= 448,
		hideBackground = true,
		maskFile 		= "images/masks/mask-320x448.png",
		onRowRender 	= function(event) return self:onRowRender(event) end,
	}

	self.view:insert( list )

	----------------------
	
	events = {}

	if(selectedJourney ~= nil and #selectedJourney.events > 0 ) then
		for i in pairs(selectedJourney.events) do
			if(selectedJourney.events[i].content.type == eventManager.MESSAGE) then
				table.insert(events, selectedJourney.events[i])
				accountManager.readEvent(selectedJourney.events[i])
   		end
		end
	end
	
	--- json to table for the event.sender
	for i in pairs(events) do
		if type(events[i].sender) ~= "table" then events[i].sender = json.decode(events[i].sender) end
		if type(events[i].recepient) ~= "table" then events[i].recepient = json.decode(events[i].recepient) end
	end
	
	--- get all linkedin profiles
	local ids = {}
	for i in pairs(events) do
		if(events[i].sender.linkedinUID ~= "none") then
			table.insert(ids, events[i].sender.linkedinUID)
   	end
	end

	if(accountManager.user.isConnected) then
		linkedIn.getProfiles(ids, function(event) return self:drawList() end)
	else 
		self:drawList()
	end

end

function scene:drawList()
	for i in pairs(events) do
		self:createRow() 
	end
	
	native.setActivityIndicator( false )
end

-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	list:insertRow
	{
		rowHeight = 164,
		rowColor = 
		{ 
			default = { 255, 255, 255, 0 },
		}
	}
end

----------------------
--- Handle row rendering
--	

function scene:onRowRender( event )
	local phase = event.phase
	local row = event.row
	local message = events[row.index];

	---------

	if(not message.sender.pictureUrl) then
		message.sender.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
	end
	
	---------
		
	imagesManager.drawImage(
		row, 
		message.sender.pictureUrl, 
		5, 5,	
		IMAGE_TOP_LEFT, 0.4,
		false,
		function(picture)
			self:rowRenderContent(row, picture, message)
		end
	)

end

function scene:rowRenderContent( row, picture, message )
	
	local openProfile = function() router.displayProfile(message.sender.linkedinUID, message.sender.uid, router.openJourneyMessages) end
	picture:addEventListener("tap", openProfile)

	---------

	if(message.sender.linkedinUID ~= accountManager.user.linkedinUID) then
   	local travelerName = display.newText( message.sender.name .. " :", 50, 10, 205, 30, native.systemFontBold, 14 )
   	travelerName:setTextColor( 0 )
   	row:insert(travelerName)
		self:rowRenderText(row, nil, message)
   else

   	local recepientName = display.newText( "Sent to " .. message.recepient.name, 0, 20, 205, 30, native.systemFont, 11 )
   	recepientName:setTextColor( 0 )
   	recepientName.x = row.contentWidth - 20 - recepientName.contentWidth/2
   	row:insert(recepientName)

   	imagesManager.drawImage(
   		row, 
   		linkedIn.data.people[message.recepient.linkedinUID].pictureUrl, 
   		row.contentWidth - 50, 5,	
   		IMAGE_TOP_LEFT, 0.4,
   		false,
   		function(picture)
   			self:rowRenderText(row, picture, message)
   		end
   	)
   end


	-----------
end

function scene:rowRenderText( row, picture, message )

	if(picture) then
   	local openProfile = function() router.displayProfile(message.recepient.linkedinUID, message.recepient.uid, router.openJourneyMessages) end
   	picture:addEventListener("tap", openProfile)
	end
	
	local text = display.newText( message.content.text, 50, 50, 205, 100, native.systemFont, 14 )
	text:setTextColor( 0 )
	row:insert(text)
	
	if(message.sender.linkedinUID ~= accountManager.user.linkedinUID) then
   	local answerButton = widget.newButton	{
   		width = 55,
   		height = 25,
   		fontSize = 10,
   		label = "Answer", 
   		labelYOffset = 2,
   		onRelease = function() self.openWriter(message) end
   	}
   	
   	answerButton.x = display.contentWidth - answerButton.width - 10
   	answerButton.y = text.y + text.contentHeight/2 - 10
   	
   	row:insert( answerButton ) 
	end
end


function scene:openWriter()
	if(#events > 0) then
      analytics.event("Message", "startAnswer") 
      
		router.openWriteMessage(events[#events], true, router.openJourneyMessages)
	end
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene(event.params.back);
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