-----------------------------------------------------------------------------------------
--
-- trips.lua
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()

--- The elements
local tripView

-----------------------------------------------------------------------------------------
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	tripView = display.newGroup()
	details  = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()

	viewManager.setupView(self.view, tripManager.closeWebWindow)
	self:addTripsButtons()
	
	self:buildTripView()

	self:showTrips()
end

-----------------------------------------------------------------------------------------
--- tripit DEPRECATED v1
--
--function syncWithTripit()
--	 tripit.authorise(accountManager.getTripitProfileAndTrips, cancelTripit)
--    analytics.event("Trip", "sync") 
--end
--
--function afterCreateTrip()
--	tripit.openNewTripWindow(accountManager.syncTripsWithTripit)
--end
--
--function createTrip()
--	tripit.authorise(afterCreateTrip, cancelTripit)
--   analytics.event("Trip", "create") 
--end
--
--function cancelTripit()
--   analytics.event("Trip", "cancelCreation") 
--	print('cancel tripit')
--end

-----------------------------------------------------------------------------------------

function scene:createTrip()
   tripManager.openNewTripWindow()

--   analytics.event("Trip", "create")
--   tripManager.openNewJourneyWindow()
	--tripManager.createTrip()
--	self:refreshScene()
end

-----------------------------------------------------------------------------------------

function scene:buildTripView()

	----------------------
	
	self:hideNoTrips()
	utils.emptyGroup(tripView)

	----------------------
	local noTripText = display.newText( "No Trip", 0, 0, native.systemFontBold, 28 )
	noTripText:setTextColor( 0 )
	noTripText.x = display.contentWidth/2
	noTripText.y = display.contentCenterY
	noTripText.alpha = 0
	
	tripView:insert( noTripText )
	tripView.noTripText = noTripText

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

	tripView:insert( list )
	tripView.list = list
	
	----------------------

	self.view:insert(tripView)
	
	----------------------
	-- insert rows into list (tableView widget)
	-- 
 	if( #accountManager.user.trips == 0) then
 		self:showNoTrips();
 	else
		for i in pairs(accountManager.user.trips) do
			self.createRow()
		end
 	end		
end

-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	tripView.list:insertRow
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
	local tripRendered = accountManager.user.trips[row.index];

	local title = display.newText( tripRendered.name, 0, 0, native.systemFontBold, 16 )
	title:setTextColor( 0 )
	title.x = row.x - ( row.contentWidth * 0.5 ) + ( title.contentWidth * 0.5 ) + 50
	title.y = 22
	row:insert(title)

	local arrow = display.newImage( "images/buttons/rowArrow.png", false )
	arrow.x = row.contentWidth - arrow.contentWidth - 10
	arrow.y = row.contentHeight * 0.5
	row:insert(arrow)

	imagesManager.drawImage(
		row, 
		tripRendered.imageUrl, 
		10, 5, 
		IMAGE_TOP_LEFT, 1,
		false,
		function(picture)
			self:rowRenderContent(row, tripRendered)
		end
	)
end

function scene:rowRenderContent (row, trip)

	if(trip.journeys ~= nil and #trip.journeys > 0) then

		-----------------------
   
   	if(trip.journeys[1].startTime) then
      	local startTime = display.newText( os.date("%d %b, %Y   %H:%M", trip.journeys[1].startTime/1000), 47, row.contentHeight - 20, native.systemFont, 11 )
      	startTime:setTextColor( 0 )
      	row:insert(startTime)
      end
   	
   	if(trip.journeys[#trip.journeys].endTime) then
      	local endTime = display.newText( os.date("%d %b, %Y   %H:%M", trip.journeys[#trip.journeys].endTime/1000), 177, row.contentHeight - 20, native.systemFont, 11 )
      	endTime:setTextColor( 0 )
      	row:insert(endTime)
		end

		-----------------------

		local nbMessages 	= 0
		local nbDiligis 	= 0
	
		for j in pairs(trip.journeys) do
      	if(trip.journeys[j].events ~= nil and #trip.journeys[j].events > 0) then
      		for i in pairs(trip.journeys[j].events) do
      			if(trip.journeys[j].events[i].content.type == eventManager.MESSAGE) then
      				nbMessages = nbMessages + 1
      			elseif(trip.journeys[j].events[i].content.type == eventManager.DILIGIS) then
      				nbDiligis = nbDiligis + 1
      			end
      		end
   		end
		end

		if(nbMessages > 0) then
      	--- messages icon
      	local messagesIcon = display.newImage ( "images/icons/messages.icon.png", false) 
      	messagesIcon.x = row.contentWidth/2 + 30 
      	messagesIcon.y = row.contentHeight/3
      
      	row:insert( messagesIcon )
      	
      	local messagesCount = display.newText( nbMessages, 0, 0, native.systemFontBold, 16 )
      	messagesCount:setTextColor( 0 )
      	messagesCount.x = messagesIcon.x - 30
      	messagesCount.y = row.contentHeight/3
      	row:insert(messagesCount)
   	end
   	
		if(nbDiligis > 0) then
      	--- diligis icon
      	local diligisIcon = display.newImage ( "images/icons/diligis.icon.png", false) 
      	diligisIcon.x = row.contentWidth/2 + 95 
      	diligisIcon.y = row.contentHeight/3
      
      	row:insert( diligisIcon )

      	local diligisCount = display.newText( nbDiligis, 0, 0, native.systemFontBold, 16 )
      	diligisCount:setTextColor( 0 )
      	diligisCount.x = diligisIcon.x - 30
      	diligisCount.y = row.contentHeight/3
      	row:insert(diligisCount)
   	end
   	
   	
	end
end

----------------------
-- Handle row touch events
function scene:onRowTouch( event )
	local phase = event.phase
	local row = event.target
	GLOBALS.selectedTrip = accountManager.user.trips[row.index];

	if "release" == phase then
		local go = function() router.openJourneys(router.displayTrips) end
      transition.to( tripView,  { x = -display.contentWidth * 1.5 , time = 400, transition = easing.inExpo, onComplete = go } )
	end
	
end

-----------------------------------------------------------------------------------------

--function scene:buildDetails()
--
--	----------------------
--
--	utils.emptyGroup(details)
--	
--	----------------------
--
--	local address = display.newText( "", 0, 0, native.systemFontBold, 16 )
--	address:setTextColor( 0 )
--	address.x = display.contentWidth * 0.5
--	address.y = 200
--
--	details:insert( address )
--	details.address = address 
--
--	----------------------
--
--	local startDate = display.newText( "", 0, 0, native.systemFontBold, 13 )
--	startDate:setTextColor( 0 )
--	startDate.x = display.contentWidth * 0.5
--	startDate.y = 250
--
--	details:insert( startDate )
--	details.startDate = startDate
--	 
--	----------------------
--
--	local endDate = display.newText( "", 0, 0, native.systemFontBold, 13 )
--	endDate:setTextColor( 0 )
--	endDate.x = display.contentWidth * 0.5
--	endDate.y = 290
--
--	details:insert( endDate )
--	details.endDate = endDate 
--
--	----------------------
--
--	--- messages icon
--	local messagesIcon = display.newImage ( "images/icons/messages.icon.png", false) 
--	messagesIcon.x = 100 
--	messagesIcon.y = 360
--	messagesIcon:addEventListener("tap", function() router.openJourneyMessages(router.openTrips) end)
--
--	details:insert( messagesIcon )
--	details.messagesIcon = messagesIcon 
--	
--	local messagesCount = display.newText( "", 0, 0, native.systemFontBold, 16 )
--	messagesCount:setTextColor( 0 )
--	messagesCount.x = messagesIcon.x - 30
--	messagesCount.y = 360
--	messagesCount:addEventListener("tap", function() router.openJourneyMessages(router.openTrips) end)
--
--	details:insert(messagesCount)
--	details.messagesCount = messagesCount 
--
--	--- diligis icon
--	local diligisIcon = display.newImage ( "images/icons/diligis.icon.png", false) 
--	diligisIcon.x = 250 
--	diligisIcon.y = 360
--	diligisIcon:addEventListener("tap", function() router.openJourneyDiligis(router.openTrips) end)
--
--	details:insert(diligisIcon)
--	details.diligisIcon = diligisIcon 
--
--	local diligisCount = display.newText( "", 0, 0, native.systemFontBold, 16 )
--	diligisCount:setTextColor( 0 )
--	diligisCount.x = diligisIcon.x - 30
--	diligisCount.y = 360
--	diligisCount:addEventListener("tap", function() router.openJourneyDiligis(router.openTrips) end)
--	
--	details:insert(diligisCount)
--	details.diligisCount = diligisCount 
--
--	------------------------------------------------
--	
--	details.x = display.contentWidth + display.contentWidth * 0.5
--	details.y = 0
--	
--	----------------------
--	
--	self.view:insert(details)
--end

-----------------------------------------------------------------------------------------

function scene:addTripsButtons()
	viewManager.addCustomButton("images/buttons/add.png", function () return self:createTrip() end);
end

-----------------------------------------------------------------------------------------
--- states/transitions

function scene:showNoTrips()
	transition.to( tripView.noTripText, { alpha = 1.0 } )
end

function scene:hideNoTrips()
	transition.to( tripView.noTripText, { alpha = 0 } )
end

function scene:showDetails()
	transition.to( tripView, { x = - display.contentWidth, time = 400, transition = easing.outExpo } )
	transition.to( details,  { x = 0, time = 400, transition = easing.outExpo } )
	viewManager.removeAllButtons()
	viewManager.addCustomButton("images/buttons/leftArrow.png", function() self:showTrips() end);
end

function scene:showTrips()
	transition.to( tripView, { x = 0, time = 400, transition = easing.outExpo } )
	transition.to( details,  { x = display.contentWidth + display.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	viewManager.removeAllButtons()
	self:addTripsButtons()
end

-----------------------------------------------------------------------------------------

--- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene();
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