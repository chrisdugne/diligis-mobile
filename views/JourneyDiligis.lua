-----------------------------------------------------------------------------------------
--
-- JourneyDiligis.lua
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
	self:buildDiligis();
end
	
-----------------------------------------------------------------------------------------

function scene:buildDiligis()

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
	
	events = {}

	if( GLOBALS.selectedJourney ~= nil 
	and GLOBALS.selectedJourney.events ~= nil 
	and #GLOBALS.selectedJourney.events > 0 )
	then
		for i in pairs(GLOBALS.selectedJourney.events) do
			if(GLOBALS.selectedJourney.events[i].content.type == eventManager.DILIGIS) then
				table.insert(events, GLOBALS.selectedJourney.events[i])
   		end
		end
	end


	--- get all linkedin profiles
	local ids = {}
	for i in pairs(events) do
		if type(events[i].sender) ~= "table" then events[i].sender = json.decode(events[i].sender) end
		if events[i].recepient and type(events[i].recepient) ~= "table" then events[i].recepient = json.decode(events[i].recepient) end
		
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
		rowHeight = 144,
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
	local diligis = events[row.index]
	local me = self

	---------
--
--	if(not diligis.sender.pictureUrl) then
--		diligis.sender.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
--	end
	
	---------
	
	imagesManager.drawImage(
		row, 
		linkedIn.data.people[diligis.sender.linkedinUID].pictureUrl , 
		30, row.height * 0.5,
		IMAGE_CENTER, 0.6,
		false,
		function(picture) return me:rowRenderContent(row, picture, diligis) end
	)
	
end

function scene:receivedPicture(picture)
	self:rowRenderContent(row, picture, diligis)
end
	
function scene:rowRenderContent( row, picture, diligis )

	local openProfile = function() router.displayProfile(diligis.sender.linkedinUID, diligis.sender.uid, router.openJourneyDiligis) end
	picture:addEventListener("tap", openProfile)

	---------
	
	local text = display.newText( diligis.content.text, 0, 0, 270, 50, native.systemFont, 14 )
	text:setTextColor( 0 )
	text.x = 205
	text.y = 30
	row:insert(text)
	
	local senderName = display.newText( diligis.sender.name, 0, 0, 270, 50, native.systemFontBold, 14 )
	senderName:setTextColor( 0 )
	senderName.x = 205
	senderName.y = 70
	row:insert(senderName)

	local senderProfile = display.newText( diligis.sender.headline, 0, 0, 270, 50, native.systemFont, 14 )
	senderProfile:setTextColor( 0 )
	senderProfile.x = 205
	senderProfile.y = 90
	row:insert(senderProfile)

	---------
	
	local writeTo = display.newText( "Write a message : ", 0, 0, 270, 50, native.systemFont, 14 )
	writeTo:setTextColor( 0 )
	writeTo.x = 235
	writeTo.y = 120
	row:insert(writeTo)

	local write = function() self:openWriter(diligis) end
	
	local message = widget.newButton{
		defaultFile	= "images/icons/messages.icon.png", 
		overFile		= "images/icons/messages.icon.png", 
		onRelease	= write,
		left 			= writeTo.x + 50, 
		top 			= writeTo.y - 15
   }
   
	row:insert(message)
	
end

function scene:openWriter(diligis)
   analytics.event("Message", "startTalking") 
   router.openWriteMessage(diligis, true)
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