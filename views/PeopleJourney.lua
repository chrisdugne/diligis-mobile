-----------------------------------------------------------------------------------------
--
-- PeopleJourney.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local event
local user
local journey
local journeyContent

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	journeyContent = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene(announcement, back)
	event = announcement
	user 	= announcement.sender
	viewManager.setupView(self.view);
	viewManager.addCustomButton("images/buttons/leftArrow.png", back);
	
	if(not user.pictureUrl) then
		user.pictureUrl = "http://static.licdn.com/scds/common/u/img/icon/icon_no_photo_60x60.png"
	end
	
	if(user.linkedinUID == "none" or not accountManager.user.isConnected) then
		self:getJourney() 
	else
		linkedIn.getProfiles({user.linkedinUID}, function(event) return self:getJourney() end) 
   end
end

-----------------------------------------------------------------------------------------

function scene:getJourney()
	native.setActivityIndicator( true )
	utils.postWithJSON({
		journeyId = user.journeyId;
	},
	SERVER_URL .. "/getJourney", 
	function(event) self:getJourneyListener(event) end)
end

function scene:getJourneyListener( event )
	journey = json.decode(event.response);

	utils.emptyGroup(journeyContent)
	self:drawPicture();
end

-----------------------------------------------------------------------------------------

function scene:drawPicture()

	imagesManager.drawImage(
		journeyContent, 
		linkedIn.data.people[user.linkedinUID].pictureUrl, 
		20, 20,
		IMAGE_TOP_LEFT, 0.6,
		false,
		function(picture) return self:buildJourney(picture) end
	)
	
end

-----------------------------------------------------------------------------------------

function scene:buildJourney(picture)
	

	local senderName = display.newText( user.name, 0, 0, 270, 50, native.systemFontBold, 14 )
	senderName:setTextColor( 0 )
	senderName.x = 215
	senderName.y = 40
	journeyContent:insert(senderName)

	local senderProfile = display.newText( user.headline, 0, 0, 100, 100, native.systemFont, 14 )
	senderProfile:setTextColor( 0 )
	senderProfile.x = 135
	senderProfile.y = 100
	journeyContent:insert(senderProfile)

	----------------------
	
	local locationName
	
	-- diligis annoucement
	if(not journey) then
		self.view:insert( journeyContent )
		native.setActivityIndicator( false )
		return
	end

	-----------------------

	local openProfile = function() router.displayProfile(user.linkedinUID, user.uid, router.openStream) end
	picture:addEventListener("tap", openProfile)

	-----------------------
	
	local iconImage
	if(journey.type == tripManager.DESTINATION) then
		iconImage = "images/icons/destination.png"
	elseif(journey.type == tripManager.FLIGHT) then
		iconImage = "images/icons/plane.png"
	elseif(journey.type == tripManager.TRAIN) then
		iconImage = "images/icons/train.png"
	end

	local icon = display.newImage( iconImage, false )
	icon.x = 50
	icon.y = 130
	journeyContent:insert(icon)

	-----------------------

	if(journey.type == tripManager.DESTINATION) then
		locationName = journey.locationName
	elseif(journey.type == tripManager.FLIGHT) then
		locationName = "Flight from " .. journey.previousLocationName
	elseif(journey.type == tripManager.TRAIN) then
		locationName = "Train from " .. journey.previousLocationName
	end

	local locationName = display.newText( locationName, 0, 0, 150, 50, native.systemFontBold, 12 )
	locationName:setTextColor( 0 )
	locationName.x = 155
	locationName.y = 140

	journeyContent:insert( locationName )
	journeyContent.locationName = locationName

	----------------------
	
	local departureText
	
	if(journey.type == tripManager.DESTINATION) then
		departureText = "From " .. os.date("%m %b, %Y", journey.startTime/1000)
	elseif(journey.type == tripManager.FLIGHT) then
		departureText = journey.startAirport .. "   " .. os.date("%m %b, %Y    %H:%M", journey.startTime/1000)
	elseif(journey.type == tripManager.TRAIN) then
		departureText = os.date("%m %b, %Y    %H:%M", journey.startTime/1000)
	end

	local startText = display.newText( departureText, 0, 0, native.systemFont, 10 )
	startText:setTextColor( 0 )
	startText.x = 145
	startText.y = 180

	journeyContent:insert( startText )
	journeyContent.startText = startText
	 
	----------------------
	
	if(journey.endTime) then
   	
   	local arrivalText 
   	
   	if(journey.type == tripManager.DESTINATION) then
   		arrivalText = "To    " .. os.date("%m %b, %Y", journey.endTime/1000)
   	elseif(journey.type == tripManager.FLIGHT) then
   		arrivalText = journey.endAirport .. "   " .. os.date("%m %b, %Y    %H:%M", journey.endTime/1000)
   	elseif(journey.type == tripManager.TRAIN) then
   		arrivalText = os.date("%m %b, %Y    %H:%M", journey.endTime/1000)
   	end
   	
   	local endText = display.newText( arrivalText, 0, 0, native.systemFont, 10 )
   	endText:setTextColor( 0 )
   	endText.x = 145
   	endText.y = 200
   
   	journeyContent:insert( endText )
   	journeyContent.endText = endText
   end 

	-----------------------
	

	if(journey.type == tripManager.FLIGHT) then
   	local flightDetails = journey.number
   	if(#journey.airline > 0) then
   		flightDetails = "With " .. journey.airline .. ", flight : " .. journey.number
   	else
   		flightDetails = "Flight : " .. journey.number
   	end
   	
   	
   	local detailsText = display.newText( flightDetails, 0, 0, 150, 50, native.systemFont, 14 )
   	detailsText:setTextColor( 0 )
   	detailsText.x = 155
   	detailsText.y = 250
   
   	journeyContent:insert( detailsText )
   	journeyContent.detailsText = detailsText
	end

	----------------------
	
	local writemeText
	
	if(journey.type == tripManager.DESTINATION) then
		writemeText = "If you'll be at the same destination on any day that I'm there, let's arrange to meet up ?"
	elseif(journey.type == tripManager.FLIGHT) then
		writemeText = "If you're taking the same flight, send me a note so we arrange to meet up"
	elseif(journey.type == tripManager.TRAIN) then
		writemeText = "If you're taking the same train, send me a note so we arrange to meet up"
	end
	
	local writemeDisplay = display.newText( writemeText, display.contentWidth * 0.5 - 100, 280, 200, 200, native.systemFont, 11 )
	writemeDisplay:setTextColor( 0 )

	journeyContent:insert( writemeDisplay )

	---------
	
	local writeTo = display.newText( "Send a message : ", 0, 0, 230, 50, native.systemFont, 14 )
	writeTo:setTextColor( 0 )
	writeTo.x = 185
	writeTo.y = display.contentHeight - 100
	journeyContent:insert(writeTo)

	
	local message = widget.newButton{
		defaultFile	= "images/icons/messages.icon.png", 
		overFile		= "images/icons/messages.icon.png", 
		onRelease	= writeAMessage,
		left 			= writeTo.x + 15, 
		top 			= writeTo.y - 25
   }
   
	journeyContent:insert(message)
	
	------------------------------------------------
	
	self.view:insert( journeyContent )

	----------------------

	native.setActivityIndicator( false )
end

function writeAMessage()
   analytics.event("Message", "startTalkingFromPeopleJourney") 
   router.openWriteMessage(event, false, router.openStream)
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	if event.params then
		self:refreshScene(event.params.announcement, event.params.back);
	end

	journeyContent.x = -display.contentWidth * 1.5
	journeyContent.y = 60
	transition.to( journeyContent,  { x = 0 , time = 400, transition = easing.outExpo } )
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