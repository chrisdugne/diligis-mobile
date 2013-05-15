-----------------------------------------------------------------------------------------
--
-- trips.lua
--
-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()

--- The elements
local tripView, details

--- Many settings
local syncwithX 		= display.contentWidth 	* 0.38
local syncwithY 		= display.contentHeight * 0.93
local tripitButtonX 	= 50
local tripitButtonY 	= display.contentHeight * 0.93

-----------------------------------------------------------------------------------------
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	----------------------
	tripit.init();

 	----------------------

	tripView = display.newGroup()
	details  = display.newGroup()
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()

	viewTools.setupView(self.view);
 	
	self:buildTripView();
	self:buildDetails();

	showTrips()
end

-----------------------------------------------------------------------------------------

function scene:buildTripView()

	----------------------
	
	hideNoTrips()
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
	---- tripit sync button
	local syncWithTripit = function() return tripit.authorise(accountManager.getTripitProfileAndTrips, self.cancelTripit) end
	local tripitButton = ui.newButton{
		default		= "images/buttons/refresh.png", 
		over			= "images/buttons/refresh.png", 
		onRelease	= syncWithTripit, 
		x 				= tripitButtonX,
		y 				= tripitButtonY 
	}
	
	tripView:insert( tripitButton )
	tripView.tripitButton = tripitButton

	---- tripit create button
	local afterCreateTrip 	= function() return tripit.openNewTripWindow(accountManager.syncTripsWithTripit) end
	local createTrip 			= function() return tripit.authorise(afterCreateTrip, self.cancelTripit) end
	
	local createTripButton = ui.newButton{
		default		= "images/buttons/add.png", 
		over			= "images/buttons/add.png", 
		onRelease	= createTrip, 
		x 				= display.contentWidth - tripitButtonX,
		y 				= tripitButtonY 
	}
	
	tripView:insert( createTripButton )
	tripView.createTripButton = createTripButton

	----------------------
	-- Create a tableView

	local list = widget.newTableView{
		top 				= 38,
		width 			= 320, 
		height 			= 348,
		hideBackground = true,
		maskFile 		= "images/masks/mask-320x348.png",
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
 	if(accountManager.user.trips == nil or table.getn(accountManager.user.trips) == 0) then
 		showNoTrips();
 	else
		for i in pairs(accountManager.user.trips) do
			imagesManager.fetchImage(accountManager.user.trips[i].imageUrl, self.createRow) 
		end
 	end		
end

function scene:cancelTripit()
	print('cancel tripit')
end

-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	tripView.list:insertRow
	{
		rowHeight = 104,
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

	local title = display.newText( tripRendered.displayName, 0, 0, native.systemFontBold, 16 )
	title:setTextColor( 0 )
	title.x = row.x - ( row.contentWidth * 0.5 ) + ( title.contentWidth * 0.5 ) + 50
	title.y = 22
	row:insert(title)

	local arrow = display.newImage( "images/buttons/rowArrow.png", false )
	arrow.x = row.x + ( display.contentWidth * 0.5 ) - arrow.contentWidth
	arrow.y = row.contentHeight * 0.5
	row:insert(arrow)

	imagesManager.drawImage( row, tripRendered.imageUrl, 10, 5, IMAGE_TOP_LEFT, 0.3)
	
	--- find button (diligis)
	local findButton = display.newImage ( "images/icons/diligis.icon.png", false) 
	findButton.x = row.x + 10 
	findButton.y = row.contentHeight - 35

	row:insert( findButton )

	--- messages button (messages)
	local messagesButton = display.newImage ( "images/icons/messages.icon.png", false) 
	messagesButton.x = row.x + 50
	messagesButton.y = row.contentHeight - 35

	row:insert( messagesButton )
end

----------------------
-- Handle row touch events
function scene:onRowTouch( event )
	local phase = event.phase
	local row = event.target
	local trip = accountManager.user.trips[row.index];

	if "release" == phase then
		details.tripSelectedText.text = trip.displayName
		details.address.text 			= trip.address
		details.startDate.text 			= "From " .. trip.startDate
		details.endDate.text 			= "To "   .. trip.endDate
		details.tripSelectedImage 		= imagesManager.drawImage(details, trip.imageUrl, display.contentCenterX, 100, IMAGE_CENTER, 1)
		
		showDetails()
	end
end

-----------------------------------------------------------------------------------------

function scene:buildDetails()

	----------------------

	utils.emptyGroup(details)
	
	----------------------

	local backButton = widget.newButton	{
		width = display.contentWidth/3,
		height = 56,
		label = "Back", 
		labelYOffset = - 1,
		onRelease = showTrips
	}
	
	backButton.x = display.contentCenterX
	backButton.y = display.contentHeight - backButton.contentHeight
	
	details:insert( backButton )
	details.backButton = backButton 

	----------------------
	
	local tripSelectedText = display.newText( "", 0, 0, native.systemFontBold, 28 )
	tripSelectedText:setTextColor( 0 )
	tripSelectedText.x = display.contentWidth * 0.5
	tripSelectedText.y = 200

	details:insert( tripSelectedText )
	details.tripSelectedText = tripSelectedText 

	----------------------

	local address = display.newText( "", 0, 0, native.systemFontBold, 16 )
	address:setTextColor( 0 )
	address.x = display.contentWidth * 0.5
	address.y = 240

	details:insert( address )
	details.address = address 

	----------------------

	local startDate = display.newText( "", 0, 0, native.systemFontBold, 16 )
	startDate:setTextColor( 0 )
	startDate.x = display.contentWidth * 0.5
	startDate.y = 320

	details:insert( startDate )
	details.startDate = startDate
	 
	----------------------

	local endDate = display.newText( "", 0, 0, native.systemFontBold, 16 )
	endDate:setTextColor( 0 )
	endDate.x = display.contentWidth * 0.5
	endDate.y = 360

	details:insert( endDate )
	details.endDate = endDate 

	----------------------
	
	details.x = display.contentWidth + display.contentWidth * 0.5
	details.y = 0
	
	----------------------
	
	self.view:insert(details)
end

-----------------------------------------------------------------------------------------
--- states/transitions

function showNoTrips()
	transition.to( tripView.noTripText, { alpha = 1.0 } )
end

function hideNoTrips()
	transition.to( tripView.noTripText, { alpha = 0 } )
end

function showDetails()
	transition.to( tripView, { x = - display.contentWidth, time = 400, transition = easing.outExpo } )
	transition.to( details,  { x = 0, time = 400, transition = easing.outExpo } )
end

function showTrips()
	transition.to( tripView, { x = 0, time = 400, transition = easing.outExpo } )
	transition.to( details,  { x = display.contentWidth + display.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
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