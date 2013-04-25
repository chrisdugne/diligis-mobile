-----------------------------------------------------------------------------------------
--
-- view1.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local tripit = require("libs.social.Tripit")

--- The elements
-- 
local menu, stream

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )

	----------------------
	--- reset + header
	viewTools.drawHeader(self.view);
 	
 	----------------------

	menu 	= display.newGroup()
	stream  = display.newGroup()

 	----------------------
	
	self:buildMenu();
end
	
-----------------------------------------------------------------------------------------

function scene:refreshScene()
	self:buildStream();
end
		
-----------------------------------------------------------------------------------------

function scene:buildMenu()

	utils.emptyGroup(menu)
	
	--- trips button
	local openTripsAction = function() return router.openTrips() end;
	local tripsButton = ui.newButton{
		default="images/buttons/trips.medium.png", 
		over="images/buttons/trips.medium.png", 
		onRelease=openTripsAction, 
		x = display.contentWidth * (25/100), y = display.contentHeight - 40,
	}

	menu:insert( tripsButton )
	menu.tripsButton = tripsButton;

	--- find button
	local openFinderAction = function() return router.openFinder() end;
	local findButton = ui.newButton{
		default="images/buttons/find.medium.png", 
		over="images/buttons/find.medium.png", 
		onRelease=openFinderAction, 
		x = display.contentWidth * (50/100), y = display.contentHeight - 40,
	}

	menu:insert( findButton )
	menu.findButton = findButton;

	--- messages button
	local openMessagesAction = function() return router.openMessages() end;
	local messagesButton = ui.newButton{
		default="images/buttons/messages.medium.png", 
		over="images/buttons/messages.medium.png", 
		onRelease=openMessagesAction, 
		x = display.contentWidth * (75/100), y = display.contentHeight - 40,
	}

	menu:insert( messagesButton )
	menu.messagesButton = messagesButton;
	
	--- all objects must be added to group (e.g. self.view)

	self.view:insert( menu )
end
	
-----------------------------------------------------------------------------------------

function scene:buildStream()

	----------------------

	utils.emptyGroup(stream)
	
	----------------------
	-- Create a tableView
	
	local list = widget.newTableView{
		top 			= 38,
		width 			= 320, 
		height			= 348,
		hideBackground 	= true,
		maskFile 		= "images/masks/mask-320x348.png",
		onRowRender 	= function(event) return self:onRowRender(event) end,
		onRowTouch 		= function(event) return self:onRowTouch(event) end
	}

	stream:insert( list )
	stream.list = list

	----------------------
	
	self.view:insert( stream )

	----------------------
	-- 
	for i in pairs(eventManager.stream) do
		self:createRow() 
	end
end


-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	stream.list:insertRow
	{
		rowHeight = 120,
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
	local eventRendered = eventManager.stream[row.index];

	local title = display.newText( eventRendered.text, 0, 0, 200, 100, native.systemFont, 14 )
	title:setTextColor( 0 )
	title.x = row.x - ( row.contentWidth * 0.5 ) + ( title.contentWidth * 0.5 ) + 50
	title.y = row.contentHeight * 0.5
	row:insert(title)

end

----------------------
-- Handle row touch events
function scene:onRowTouch( event )
	local phase = event.phase
	local row = event.target
	local eventRendered = eventManager.stream[row.index];

	if "release" == phase then
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