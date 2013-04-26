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
local tripitButtonX 	= display.contentWidth 	* 0.67
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

	----------------------
	--- reset + header
	viewTools.drawHeader(self.view);
 	
	----------------------
	
	self:buildTripView();
	self:buildDetails();

	----------------------
	
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
	
	--- 'sync with' text
	local syncwith = display.newText( "sync with", 0, 0, native.systemFont, 21 )
	syncwith:setTextColor( 0 )	
	syncwith:setReferencePoint( display.CenterReferencePoint )
	syncwith.x = syncwithX
	syncwith.y = syncwithY
	
	tripView:insert( syncwith )
	tripView.syncwith = syncwith

	---- Add demo button to screen
	local importFromTripit = function() return tripit.authorise(accountManager.verifyTripitProfile, self.cancelTripit) end
	local tripitButton = ui.newButton{
		default="images/buttons/tripit.png", 
		over="images/buttons/tripit.png", 
		onRelease=importFromTripit, 
		x = tripitButtonX,
		y = tripitButtonY 
	}
	
	tripView:insert( tripitButton )
	tripView.tripitButton = tripitButton

	----------------------
	-- Create a tableView

	local list = widget.newTableView{
		top 			= 38,
		width 			= 320, 
		height 			= 348,
		hideBackground 	= true,
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
		height = 72,
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
	title.y = row.contentHeight * 0.5
	row:insert(title)

	local arrow = display.newImage( "images/buttons/rowArrow.png", false )
	arrow.x = row.x + ( row.contentWidth * 0.5 ) - arrow.contentWidth
	arrow.y = row.contentHeight * 0.5
	row:insert(arrow)

	imagesManager.drawImage( row, tripRendered.imageUrl, 10, 5, IMAGE_TOP_LEFT, 0.3)
end

----------------------
-- Handle row touch events
function scene:onRowTouch( event )
	local phase = event.phase
	local row = event.target
	local trip = accountManager.user.trips[row.index];

	if "release" == phase then
		details.tripSelectedText.text 	= trip.displayName
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