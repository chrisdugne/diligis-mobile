-----------------------------------------------------------------------------------------
--
-- trips.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local tripit = require("libs.social.Tripit")

local user
local currentTrip

-- Forward reference for our back button & tableview
local list, backButton, syncwith, tripitButton, itemSelected

local syncwithX = display.contentWidth * 0.27
local syncwithY = display.contentHeight * 0.93
local tripitButtonX = display.contentWidth * 0.6
local tripitButtonY = display.contentHeight * 0.93

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local view = self.view
	tripit.init();
 	user = accountManager.user;
 	
	--- reset + header
	viewTools.drawHeader(view);

	----------------------
	
	drawTripList(view);
	
end

-----------------------------------------------------------------------------------------

function tripitAuthenticated()
	print ( "tripitAuthenticated" )

	local trips = {}

	for i in pairs(tripit.data.trips) do
		local trip = {
			displayName = tripit.data.trips[i].display_name.value,
			id = tripit.data.trips[i].id.value,
			startDate = tripit.data.trips[i].start_date.value,
			endDate = tripit.data.trips[i].end_date.value,
			country = tripit.data.trips[i].PrimaryLocationAddress.country.value,
			city = tripit.data.trips[i].PrimaryLocationAddress.city.value,
			latitude = tripit.data.trips[i].PrimaryLocationAddress.latitude.value,
			longitude = tripit.data.trips[i].PrimaryLocationAddress.longitude.value,
			imageUrl = tripit.data.trips[i].image_url.value,
			lastModified = tripit.data.trips[i].last_modified.value
		}

		table.insert(trips, trip)
	end

	accountManager.user.trips = trips
	accountManager.refreshTrips()
end

-----------------------------------------------------------------------------------------

function drawTripList(view)
	
	--- 'sync with' text
	syncwith = display.newText( "sync with", 0, 0, native.systemFont, 21 )
	syncwith:setTextColor( 0 )	
	syncwith:setReferencePoint( display.CenterReferencePoint )
	syncwith.x = syncwithX
	syncwith.y = syncwithY
	view:insert( syncwith )

	---- Add demo button to screen
	local importFromTripit = function() return tripit.authorise(tripitAuthenticated) end;
	tripitButton = ui.newButton{
		default="images/buttons/tripit.png", 
		over="images/buttons/tripit.png", 
		onRelease=importFromTripit, 
		x = tripitButtonX,
		y = tripitButtonY 
	}
	view:insert( tripitButton )

	----------------------
	
	--Text to show which item we selected
	itemSelected = display.newText( "Trip ", 0, 0, native.systemFontBold, 28 )
	itemSelected:setTextColor( 0 )
	itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
	itemSelected.y = display.contentCenterY
	view:insert( itemSelected )
	
	----------------------
	-- Create a tableView

	local onRowTouch = function(event) return onRowTouch(event, view) end

	list = widget.newTableView
	{
		top = 38,
		width = 320, 
		height = 348,
		hideBackground = true,
		maskFile = "images/masks/mask-320x348.png",
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	}

	--Insert widgets/images into a view
	view:insert( list )
	
	----------------------
	--Create the back button
	backButton = widget.newButton
	{
		width = 298,
		height = 56,
		label = "Back", 
		labelYOffset = - 1,
		onRelease = onBackRelease
	}
	backButton.alpha = 0
	backButton.x = display.contentCenterX
	backButton.y = display.contentHeight - backButton.contentHeight
	view:insert( backButton )

	----------------------
	-- insert rows into list (tableView widget)
	for i in pairs(user.trips) do
		imagesManager.fetchImage(user.trips[i].imageUrl, createRow) 
	end

end

function createRow()
	list:insertRow
	{
		height = 72,
		rowColor = 
		{ 
			default = { 255, 255, 255, 0 },
		}
	}
end

----------------------
-- Handle row rendering
function onRowRender( event )
	local phase = event.phase
	local row = event.row
	local tripRendered = user.trips[row.index];

	local rowTitle = display.newText( row, tripRendered.displayName, 0, 0, native.systemFontBold, 16 )
	rowTitle:setTextColor( 0 )
	rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 ) + 50
	rowTitle.y = row.contentHeight * 0.5

	local rowArrow = display.newImage( row, "images/buttons/rowArrow.png", false )
	rowArrow.x = row.x + ( row.contentWidth * 0.5 ) - rowArrow.contentWidth
	rowArrow.y = row.contentHeight * 0.5

	imagesManager.drawImage( row, tripRendered.imageUrl, 10, 5, IMAGE_TOP_LEFT, 0.3)
end

----------------------
-- Handle row touch events
function onRowTouch( event, view )
	local phase = event.phase
	local row = event.target
	currentTrip = user.trips[row.index];
	currentTrip.ui = {}

	if "release" == phase then
		-- Update the item selected text
		itemSelected.text = currentTrip.displayName

		currentTrip.ui.image = imagesManager.drawImage(view, currentTrip.imageUrl, display.contentCenterX, 100, IMAGE_CENTER, 1)

		--Transition out the list, transition in the item selected text and the back button
		transition.to( list, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
		transition.to( syncwith, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
		transition.to( tripitButton, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
		transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
		transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	end
end


----------------------
--Handle the back button release event
function onBackRelease()
	--Transition in the list, transition out the item selected text and the back button
	transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
	transition.to( syncwith, { x = syncwithX, time = 400, transition = easing.outExpo } )
	transition.to( tripitButton, { x = tripitButtonX, time = 400, transition = easing.outExpo } )
	transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	
	if(currentTrip ~= nil) then
		imagesManager.hideImage(currentTrip.ui.image)
	end
end
-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local view = self.view
	onBackRelease();	

	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local view = self.view
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)

end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local view = self.view

	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)

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