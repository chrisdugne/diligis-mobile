-----------------------------------------------------------------------------------------
--
-- Messages.lua
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

function scene:refreshScene()
	viewManager.setupView(self.view);
	self:buildMessages();
end
	
-----------------------------------------------------------------------------------------

function scene:buildMessages()
	
	print("----------- buildMessages")
	utils.tprint(accountManager.user)
	
 	if( not accountManager.user.messages or #accountManager.user.messages == 0) then
 		self:showNoMessages();
 		return
 	end	

	----------------------

	native.setActivityIndicator( true )
	
	----------------------

	list = widget.newTableView{
		top 				= HEADER_HEIGHT,
		width 			= display.contentWidth, 
		height			= display.contentHeight - HEADER_HEIGHT,
		hideBackground = true,
		maskFile 		= "images/masks/mask-".. display.contentWidth .. "x" .. display.contentHeight - HEADER_HEIGHT .. ".png",
		onRowRender 	= function(event) return self:onRowRender(event) end,
	}

	self.view:insert( list )

	----------------------
	
	local ids = {}

	----------------------

	for i in pairs(accountManager.user.messages) do
		accountManager.readEvent(accountManager.user.messages[i])

		--- json to table for the event.sender
		if type(accountManager.user.messages[i].sender) 	~= "table" then accountManager.user.messages[i].sender 	 = json.decode(accountManager.user.messages[i].sender) 		end
		if type(accountManager.user.messages[i].recepient) ~= "table" then accountManager.user.messages[i].recepient = json.decode(accountManager.user.messages[i].recepient) 	end

	--- get all linkedin profiles
		
		if(accountManager.user.messages[i].sender.linkedinUID ~= "none") then
   		table.insert(ids, accountManager.user.messages[i].sender.linkedinUID)
		end
		
		if(accountManager.user.messages[i].recepient.linkedinUID ~= "none") then
			table.insert(ids, accountManager.user.messages[i].recepient.linkedinUID)
		end
	end
	
	----------------------

	if(accountManager.user.isConnected) then
   	linkedIn.getProfiles(ids, function(event) return self:drawList() end)
   end 
	

end

function scene:drawList()
	for i in pairs(accountManager.user.messages) do
		self:createRow(accountManager.user.messages[i]) 
	end
	
	native.setActivityIndicator( false )
end

function scene:showNoMessages()
	
	local noMessageText = display.newText( "No Message", 0, 0, native.systemFontBold, 28 )
	noMessageText:setTextColor( 0 )
	noMessageText.x = display.contentWidth/2
	noMessageText.y = display.contentCenterY
	
	self.view:insert( noMessageText )
end

-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow(message)
	
	list:insertRow
	{
		rowHeight = 150,
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
	local message = accountManager.user.messages[row.index];
	
	---------
	
	if(not message.sender.pictureUrl) then
		message.sender.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
	end
		
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
	
	local text = display.newText( message.content.text, 50, 50, 205, 100, native.systemFont, 11 )
	text:setTextColor( 0 )
	row:insert(text)
	
	if(message.sender.linkedinUID ~= accountManager.user.linkedinUID) then
   	local answerButton = widget.newButton	{
   		width = 55,
   		height = 25,
   		fontSize = 10,
   		label = "Answer", 
   		labelYOffset = 2,
   		onRelease = function() self:openWriter(message) end
   	}
   	
   	answerButton.x = row.contentWidth - answerButton.width - 10
   	answerButton.y = row.contentHeight - 30
   	
   	row:insert( answerButton ) 
	end
end


function scene:openWriter(message)
   analytics.event("Message", "startAnswer") 
	router.openWriteMessage(message, true, router.openMessages)
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene();
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