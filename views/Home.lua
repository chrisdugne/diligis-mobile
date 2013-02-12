-----------------------------------------------------------------------------------------
--
-- view1.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local tripit = require("libs.social.Tripit")

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	--- reset + header
	viewTools.drawHeader(group);
	
	--- trips button
	local openTripsAction = function() return router.openTrips() end;
	local tripsButton = ui.newButton{
		default="images/buttons/trips.medium.png", 
		over="images/buttons/trips.medium.png", 
		onRelease=openTripsAction, 
		x = display.contentWidth * (27/100), y = display.contentHeight * (24/100),
	}

	--- find button
	local openFinderAction = function() return router.openFinder() end;
	local findButton = ui.newButton{
		default="images/buttons/find.medium.png", 
		over="images/buttons/find.medium.png", 
		onRelease=openFinderAction, 
		x = display.contentWidth * (73/100), y = display.contentHeight * (24/100),
	}

	--- messages button
	local openMessagesAction = function() return router.openMessages() end;
	local messagesButton = ui.newButton{
		default="images/buttons/messages.medium.png", 
		over="images/buttons/messages.medium.png", 
		onRelease=openMessagesAction, 
		x = display.contentWidth * (27/100), y = display.contentHeight * (48/100),
	}
	
	--- all objects must be added to group (e.g. self.view)
	group:insert( tripsButton )
	group:insert( findButton )
	group:insert( messagesButton )
end

-----------------------------------------------------------------------------------------

function tripitAuthenticated()
	print ( "tripitAuthenticated" )
	
	for i in pairs(tripit.data.trips) do
		print("trip : " .. tripit.data.trips[i].display_name.value)
	end
	
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
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