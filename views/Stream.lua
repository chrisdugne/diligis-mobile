-----------------------------------------------------------------------------------------
--
-- Streams.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()

--- The elements
-- 
local stream

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	stream  = display.newGroup()
end
	
-----------------------------------------------------------------------------------------

function scene:refreshScene()
	viewManager.setupView(self.view);
	viewManager.addCustomButton("images/buttons/refresh.png", eventManager.getStream);
	self:buildStream();
end

-----------------------------------------------------------------------------------------

function scene:buildStream()

	----------------------

	utils.emptyGroup(stream)
	
	----------------------
	-- Create a tableView
	
	local list = widget.newTableView{
		top 				= 38,
		width 			= 320, 
		height			= 448,
		hideBackground = true,
		maskFile 		= "images/masks/mask-320x448.png",
		onRowRender 	= function(event) return self:onRowRender(event) end,
		onRowTouch 		= function(event) return self:onRowTouch(event) end
	}

	stream:insert( list )
	stream.list = list

	----------------------
	
	self.view:insert( stream )

	----------------------

	if(eventManager.stream ~= nil and table.getn(eventManager.stream) > 0 ) then
		for i in pairs(eventManager.stream) do
			self:createRow() 
		end
	end
	
	transition.to( stream,  { x = 0 , time = 400, transition = easing.outExpo } )
end


-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	stream.list:insertRow
	{
		rowHeight = 54,
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
	local eventRendered = eventManager.stream[row.index];
	if type(eventRendered.sender) ~= "table" then eventRendered.sender = json.decode(eventRendered.sender) end
	if eventRendered.recepient and type(eventRendered.recepient) ~= "table" then eventRendered.recepient = json.decode(eventRendered.recepient) end

	local image
	if(eventRendered.content.type == eventManager.ANNOUNCEMENT) then
		image = "images/buttons/trip.png"
	elseif (eventRendered.content.type == eventManager.DILIGIS) then
		image = "images/buttons/diligis.png"
	elseif (eventRendered.content.type == eventManager.MESSAGE) then
		image = "images/buttons/message.png"
	end
	
	local icon = display.newImage( image, false )
	icon.x = icon.contentWidth/2 + 10
	icon.y = row.height * 0.5
	row:insert(icon)
	
	local title = display.newText( eventRendered.content.text, 0, 0, 200, 50, native.systemFont, 14 )
	title:setTextColor( 0 )
	title.x = 180
	title.y = row.height * 0.5
	row:insert(title)

end

----------------------
-- Handle row touch events
function scene:onRowTouch( _event )
	local phase = _event.phase
	local row = _event.target
	local event = eventManager.stream[row.index];

	if "release" == phase then
		local go = function() showEvent(event) end
   	transition.to( stream,  { x = -display.contentWidth * 1.5 , time = 400, transition = easing.inExpo, onComplete = go } )
	end
end

function showEvent(event)
	
	if(event.content.type == eventManager.ANNOUNCEMENT) then
		
		if(event.sender.tripId) then
         analytics.event("Navigation", "streamToTrip") 
   		router.openPeopleJourney(event, router.openStream)
		else
         analytics.event("Navigation", "streamToProfile") 
   		router.displayProfile(event.sender.linkedinUID, event.sender.uid, router.openStream)
		end
		
	elseif (event.content.type == eventManager.DILIGIS) then
		selectedJourney = getJourney(event)
		router.openJourneyDiligis(router.openStream)
      analytics.event("Navigation", "streamToDiligis") 
		
	elseif (event.content.type == eventManager.MESSAGE) then
		selectedJourney = getJourney(event)
		router.openJourneyMessages(router.openStream)
      analytics.event("Navigation", "streamToMessage") 
	end
	
end


function getJourney(diligis)
	for i in pairs(accountManager.user.trips) do
   	for j in pairs(accountManager.user.trips[i].journeys) do
      	for k in pairs(accountManager.user.trips[i].journeys[j].events) do
				if(accountManager.user.trips[i].journeys[j].events[k].uid == diligis.uid) then
					return accountManager.user.trips[i].journeys[j]
         	end
      	end
   	end
	end
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