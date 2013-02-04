-----------------------------------------------------------------------------------------
--
-- view1.lua
--

-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
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
	
	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg:setFillColor( 0 )
	
	-- create some text
	local title = display.newRetinaText( "Diligis", 0, 0, native.systemFont, 32 )
	title:setTextColor( 255 )	
	title:setReferencePoint( display.CenterReferencePoint )
	title.x = display.contentWidth * 0.5
	title.y = 125
	
	local summary = display.newRetinaText( "Loaded by the first tab 'onPress' listener\n— specified in the 'tabButtons' table.", 0, 0, 292, 292, native.systemFont, 14 )
	summary:setTextColor( 255 ) 
	summary:setReferencePoint( display.CenterReferencePoint )
	summary.x = display.contentWidth * 0.5 + 10
	summary.y = title.y + 215
	
	
	-- 
	---- Add demo button to screen
	tripit.init();
	local authorise = function() return tripit.authorise(tripitAuthenticated) end;
	button1 = ui.newButton{default="images/buttons/buttonArrow.png", over="images/buttons/buttonArrowOver.png", onRelease=authorise, x = 160, y = 360}
	-- 
	---- Add label for button
--	b1text = display.newText( "Click To Load", 0, 0, nil, 15 )
--	b1text:setTextColor( 45, 45, 45, 255 ); b1text.x = 160; b1text.y = 360
	-- 
	---- Displays App title
--	title = display.newText( "Simple Image Download", 0, 30, native.systemFontBold, 20 )
--	title.x = display.contentWidth/2                -- center title
--	title:setTextColor( 255,255,0 )

	--- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( summary )
	group:insert( button1 )
end


function tripitAuthenticated()
	print ( "tripitAuthenticated" )
	
	for i in pairs(tripit.data.trips) do
		print("trip : " .. tripit.data.trips[i].display_name.value)
	end
	
end

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