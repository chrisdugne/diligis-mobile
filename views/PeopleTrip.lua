-----------------------------------------------------------------------------------------
--
-- Peopletrip.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local event
local user
local trip
local tripContent

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	tripContent = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene(announcement, back)
	event = announcement
	user 	= announcement.sender
	viewManager.setupView(self.view);
	viewManager.addCustomButton("images/buttons/leftArrow.png", back);
		
	linkedIn.getProfiles({user.linkedinUID}, function(event) return self:getTrip() end) 
end

-----------------------------------------------------------------------------------------

function scene:getTrip()
	native.setActivityIndicator( true )
	utils.postWithJSON({
		tripId = user.tripId;
	},
	SERVER_URL .. "/getTrip", 
	function(event) self:getTripListener(event) end)
end

function scene:getTripListener( event )
	trip = json.decode(event.response);

	utils.emptyGroup(tripContent)
	self:drawPicture();
end

-----------------------------------------------------------------------------------------

function scene:drawPicture()

	imagesManager.drawImage(
		tripContent, 
		linkedIn.data.people[user.linkedinUID].pictureUrl, 
		20, 40,
		IMAGE_TOP_LEFT, 0.6,
		false,
		function(picture) return self:buildTrip() end
	)
	
end

-----------------------------------------------------------------------------------------

function scene:buildTrip()

	local senderName = display.newText( user.name, 0, 0, 270, 50, native.systemFontBold, 14 )
	senderName:setTextColor( 0 )
	senderName.x = 215
	senderName.y = 70
	tripContent:insert(senderName)

	local senderProfile = display.newText( user.headline, 0, 0, 270, 50, native.systemFont, 14 )
	senderProfile:setTextColor( 0 )
	senderProfile.x = 215
	senderProfile.y = 90
	tripContent:insert(senderProfile)

	----------------------

	local address = display.newText( trip.address, 0, 0, native.systemFontBold, 16 )
	address:setTextColor( 0 )
	address.x = display.contentWidth * 0.5
	address.y = 120

	tripContent:insert( address )
	tripContent.address = address 

	----------------------

	local startDate = display.newText( trip.startDate, 0, 0, native.systemFontBold, 13 )
	startDate:setTextColor( 0 )
	startDate.x = display.contentWidth * 0.5
	startDate.y = 140

	tripContent:insert( startDate )
	tripContent.startDate = startDate
	 
	----------------------

	local endDate = display.newText( trip.endDate, 0, 0, native.systemFontBold, 13 )
	endDate:setTextColor( 0 )
	endDate.x = display.contentWidth * 0.5
	endDate.y = 160

	tripContent:insert( endDate )
	tripContent.endDate = endDate 

	----------------------
	
	local writemeText = "If you're travelling at the same time to the same destination, send me a note so we arrange to meet up"
	local writemeDisplay = display.newText( writemeText, display.contentWidth * 0.5 - 100, 300, 200, 200, native.systemFont, 11 )
	writemeDisplay:setTextColor( 0 )

	tripContent:insert( writemeDisplay )

	---------
	
	local writeTo = display.newText( "Write a message : ", 0, 0, 230, 50, native.systemFont, 14 )
	writeTo:setTextColor( 0 )
	writeTo.x = 185
	writeTo.y = 260
	tripContent:insert(writeTo)

	
	local message = widget.newButton{
		defaultFile	= "images/icons/messages.icon.png", 
		overFile		= "images/icons/messages.icon.png", 
		onRelease	= writeAMessage,
		left 			= writeTo.x + 15, 
		top 			= writeTo.y - 25
   }
   
	tripContent:insert(message)
	
	------------------------------------------------
	
	self.view:insert( tripContent )

	----------------------

	native.setActivityIndicator( false )
end

function writeAMessage()
   analytics.event("Message", "startTalkingFromPeopleTrip") 
   router.openWriteMessage(event, false, router.openStream)
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	if event.params then
		self:refreshScene(event.params.announcement, event.params.back);
	end

	tripContent.x = -display.contentWidth * 1.5
	tripContent.y = 60
	transition.to( tripContent,  { x = 0 , time = 400, transition = easing.outExpo } )
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