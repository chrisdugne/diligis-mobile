-----------------------------------------------------------------------------------------
--
-- Journeys.lua
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local cancelNextTouch

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
	viewManager.addCustomButton("images/buttons/leftArrow.png", function() router.openTrips() tripManager.closeWebWindow() end);
	
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
	print("------- build journeys")
	utils.tprint(GLOBALS.selectedTrip.journeys)
	
 	if( #GLOBALS.selectedTrip.journeys == 0) then
 		self:showNoJourneys();
 	else
		for i in pairs(GLOBALS.selectedTrip.journeys) do
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
	local journey = GLOBALS.selectedTrip.journeys[row.index];

	-----------------------

	local locationName
	
	if(journey.type == tripManager.DESTINATION) then
		locationName = journey.locationName
	elseif(journey.type == tripManager.FLIGHT) then
		locationName = "Plane from " .. journey.previousLocationName
	elseif(journey.type == tripManager.TRAIN) then
		locationName = "Train from " .. journey.previousLocationName
	end
	
	local title = display.newText( locationName, 10, 0, native.systemFont, 11 )
	title:setTextColor( 0 )
	title.y = 22
	row:insert(title)

	-----------------------

	if(journey.startTime) then
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
   end

	-----------------------

	if(journey.startTime) then
   	local startTime = display.newText( os.date("%d %b, %Y   %H:%M", journey.startTime/1000), 47, row.contentHeight - 20, native.systemFont, 11 )
   	startTime:setTextColor( 0 )
   	row:insert(startTime)
   end
	
	if(journey.endTime) then
   	local endTime = display.newText( os.date("%d %b, %Y   %H:%M", journey.endTime/1000), 177, row.contentHeight - 20, native.systemFont, 11 )
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
	
	-----------------------

	local deleteImage = display.newImage( "images/buttons/remove.png", false )
	deleteImage.x = row.contentWidth - 30
	deleteImage.y = row.contentHeight/4
	deleteImage:addEventListener("tap",
		function()  
			native.setActivityIndicator( true )
      	timer.performWithDelay( 180,
      		function()  
         		cancelNextTouch = true
         		self:delete(row.index) 
      		end
   		, 1)
   	end
   )
	row:insert(deleteImage)
end

--------------------------------------------
--

function scene:openMessages(journey)
	GLOBALS.selectedJourney = journey
	router.openJourneyMessages(router.openTrips)
end

function scene:openDiligis(journey)
	GLOBALS.selectedJourney = journey
	router.openJourneyDiligis(router.openTrips)
end

--------------------------------------------
--

function scene:delete(journey)
	
	local next 
	if(#GLOBALS.selectedTrip.journeys == 1) then
		next = function() 
			router.openTrips()
			native.setActivityIndicator( false ) 
		end
	else
		next = function() 
      	timer.performWithDelay( 300,
      		function()  
         		self:refreshScene() 
      		end
   		, 1)
			
			native.setActivityIndicator( false ) 
		end
	end
	
	tripManager.deleteJourney(journey, next)
end

--------------------------------------------
-- Handle row touch events
function scene:onRowTouch( event )
	
	if(cancelNextTouch) then
   	cancelNextTouch = false
   	return
   end
	
	local phase = event.phase
	local row = event.target
	
	local journey = GLOBALS.selectedTrip.journeys[row.index];
	tripManager.editJourney(journey)
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