-----------------------------------------------------------------------------------------
--
-- Journeys.lua
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()

--- The elements
local journeys

-----------------------------------------------------------------------------------------
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	journeys = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()
	
	viewManager.setupView(self.view, tripManager.closeAddJourneyWindow)
	viewManager.addCustomButton("images/buttons/add.png", function () return self:createJourney() end);
	viewManager.addCustomButton("images/buttons/leftArrow.png", function() router.openTrips() tripManager.closeAddJourneyWindow() end);
	
	self:buildJourneys()
end

-----------------------------------------------------------------------------------------

function scene:createJourney()
   tripManager.openNewJourneyWindow(function() scene:refreshScene(router.openTrips) end)
end

-----------------------------------------------------------------------------------------

function scene:buildJourneys()

	----------------------
	
	self:hideNoJourneys()
	utils.emptyGroup(journeys)

	----------------------
	
	local noJourneyText = display.newText( "No journey yet", 0, 0, native.systemFontBold, 28 )
	noJourneyText:setTextColor( 0 )
	noJourneyText.x = display.contentWidth/2
	noJourneyText.y = display.contentCenterY
	noJourneyText.alpha = 0
	
	journeys:insert( noJourneyText )
	journeys.noJourneyText = noJourneyText

	----------------------
	-- Create a tableView

	local list = widget.newTableView{
		top 				= 38,
		width 			= 320, 
		height 			= 448,
		hideBackground = true,
		maskFile 		= "images/masks/mask-320x448.png",
		onRowRender 	= function(event) return self:onRowRender(event) end,
		onRowTouch 		= function(event) return self:onRowTouch(event) end
	}

	journeys:insert( list )
	journeys.list = list
	
	----------------------

	self.view:insert(journeys)
	
	----------------------
	-- insert rows into list (tableView widget)
	-- 
 	if( #selectedTrip.journeys == 0) then
 		self:showNoJourneys();
 	else
		for i in pairs(selectedTrip.journeys) do
			self.createRow()
		end
 	end		
end

-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	journeys.list:insertRow
	{
		rowHeight = 70,
		rowColor = 
		{ 
			default = { 255, 255, 255, 0 },
		}
	}
end

----------------------
--- Handle row rendering
function scene:onRowRender( event )
	local phase = event.phase
	local row = event.row
	local journey = selectedTrip.journeys[row.index];

	-----------------------

	local locationName
	
	if(journey.type == tripManager.PLACE) then
		locationName = journey.locationName
	elseif(journey.type == tripManager.PLANE) then
		locationName = "Plane from " .. journey.previousLocationName
	elseif(journey.type == tripManager.TRAIN) then
		locationName = "Train from " .. journey.previousLocationName
	end
	
	local title = display.newText( locationName, 10, 0, native.systemFont, 11 )
	title:setTextColor( 0 )
	title.y = 22
	row:insert(title)

	-----------------------

	local perlImage
	if(os.time() - journey.startTime > 0) then
		perlImage = "images/icons/green.mini.png"
	else
		perlImage = "images/icons/blue.mini.png"
	end
	
	local perl = display.newImage( perlImage, false )
	perl.x = 27
	perl.y = row.contentHeight - 20
	row:insert(perl)

	-----------------------

	local startTime = display.newText( os.date("%m.%d.%Y %H:%M", journey.startTime/1000), 47, row.contentHeight - 20, native.systemFont, 11 )
	startTime:setTextColor( 0 )
	row:insert(startTime)
	
	if(journey.endTime) then
   	local endTime = display.newText( os.date("%m.%d.%Y %H:%M", journey.endTime/1000), 177, row.contentHeight - 20, native.systemFont, 11 )
   	endTime:setTextColor( 0 )
   	row:insert(endTime)
   end

	-----------------------

	if(journey.events ~= nil and #journey.events > 0) then
	
		local nbMessages 	= 0
		local nbDiligis 	= 0
		
		for i in pairs(journey.events) do
			if(journey.events[i].content.type == eventManager.MESSAGE) then
				nbMessages = nbMessages + 1
			elseif(journey.events[i].content.type == eventManager.DILIGIS) then
				nbDiligis = nbDiligis + 1
			end
		end

		if(nbMessages > 0) then
      	--- messages icon
      	local messagesIcon = display.newImage ( "images/icons/messages.icon.png", false) 
      	messagesIcon.x = row.contentWidth - 100 
      	messagesIcon.y = row.contentHeight/3
			messagesIcon:addEventListener("tap", function() self:openMessages(journey) end)
      	
      	row:insert( messagesIcon )
      	
      	local messagesCount = display.newText( nbMessages, 0, 0, native.systemFontBold, 16 )
      	messagesCount:setTextColor( 0 )
      	messagesCount.x = messagesIcon.x - 30
      	messagesCount.y = row.contentHeight/3
			messagesCount:addEventListener("tap", function() self:openMessages(journey) end)
      	row:insert(messagesCount)
   	end
   	
		if(nbDiligis > 0) then
      	--- diligis icon
      	local diligisIcon = display.newImage ( "images/icons/diligis.icon.png", false) 
      	diligisIcon.x = row.contentWidth - 40
      	diligisIcon.y = row.contentHeight/3
			diligisIcon:addEventListener("tap", function() self:openDiligis(journey) end)
      
      	row:insert( diligisIcon )

      	local diligisCount = display.newText( nbDiligis, 0, 0, native.systemFontBold, 16 )
      	diligisCount:setTextColor( 0 )
      	diligisCount.x = diligisIcon.x - 30
      	diligisCount.y = row.contentHeight/3
			diligisCount:addEventListener("tap", function() self:openDiligis(journey) end)
      	row:insert(diligisCount)
   	end
	end
end

function scene:openMessages(journey)
	selectedJourney = journey
	router.openJourneyMessages(router.openTrips)
end

function scene:openDiligis(journey)
	selectedJourney = journey
	router.openJourneyDiligis(router.openTrips)
end

----------------------
-- Handle row touch events
function scene:onRowTouch( event )
	local phase = event.phase
	local row = event.target
--	selectedJourney = accountManager.user.trips[row.index];
--
--	if "release" == phase then
--		details.address.text 			= selectedTrip.address
--		details.startDate.text 			= "From " .. selectedTrip.startDate
--		details.endDate.text 			= "To "   .. selectedTrip.endDate
--		
--      imagesManager.drawImage(
--      	details, 
--      	selectedTrip.imageUrl,
--      	display.contentCenterX, 100,
--      	IMAGE_CENTER, 1,
--      	false,
--      	function(image)
--      		details.tripSelectedImage = image
--      	end
--      )
--		
--		local nbMessages 	= 0
--		local nbDiligis 	= 0
--   	
--   	if(selectedTrip.events ~= nil and #selectedTrip.events > 0) then
--   		for i in pairs(selectedTrip.events) do
--   			if(selectedTrip.events[i].content.type == eventManager.MESSAGE) then
--   				nbMessages = nbMessages + 1
--   			elseif(selectedTrip.events[i].content.type == eventManager.DILIGIS) then
--   				nbDiligis = nbDiligis + 1
--   			end
--   		end
--   	end
--   	
--   	if(nbDiligis > 0) then
--   		details.diligisCount.text 	= nbDiligis
--   		details.diligisCount.alpha = 1
--   		details.diligisIcon.alpha 	= 1
--   	else
--   		details.diligisCount.alpha = 0
--   		details.diligisIcon.alpha 	= 0
--   	end
--   	
--   	if(nbMessages > 0) then
--   		details.messagesCount.text  = nbMessages
--   		details.messagesCount.alpha = 1
--   		details.messagesIcon.alpha  = 1
--   	else
--   		details.messagesCount.alpha = 0
--   		details.messagesIcon.alpha  = 0
--   	end
--   	
--		showDetails()
--	end
end

-----------------------------------------------------------------------------------------
--- states/transitions

function scene:showNoJourneys()
	transition.to( journeys.noJourneyText, { alpha = 1.0 } )
end

function scene:hideNoJourneys()
	transition.to( journeys.noJourneyText, { alpha = 0 } )
end

-----------------------------------------------------------------------------------------

--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene(event.params.back)
end

--- Called when scene is about to move offscreen:
function scene:exitScene( event )
end

--- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
end

-----------------------------------------------------------------------------------------

--- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

--- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

--- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

--- "destroyScene" event is dispatched before view is unloaded, which can be
--- automatically unloaded in low memory situations, or explicitly via a call to
--- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene