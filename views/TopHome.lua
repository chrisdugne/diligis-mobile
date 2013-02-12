-----------------------------------------------------------------------------------------
--
-- tophome.lua
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
	
	--- bg
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	
	--- logo
	local logo = display.newImage( "images/logos/d_logo.png" )
	logo.x = display.contentWidth/2
	logo.y = display.contentHeight/4
	
	--- sign in text
	local signin = display.newRetinaText( "sign in", 0, 0, native.systemFont, 21 )
	signin:setTextColor( 0 )	
	signin:setReferencePoint( display.CenterReferencePoint )
	signin.x = display.contentWidth * 0.5
	signin.y = 3*display.contentHeight/4 - 45
		
	--- in button
	local signinAction = function() return linkedInConnect() end;
	local openHomeAction = function() return router.openHome() end;
	local signinButton = ui.newButton{
		default="images/buttons/linkedin.medium.png", 
		over="images/buttons/linkedin.medium.png", 
	--	onRelease=signinAction, 
		onRelease=openHomeAction, 
		x = display.contentWidth/2, y = 3*display.contentHeight/4+20,
	}
	
	--- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( logo )
	group:insert( signin )
	group:insert( signinButton )
end

------------------------------------------

local function linkedInConnect()
	linkedIn.init();
	linkedIn.authorise(linkedInConnected);
end

function linkedInConnected()
	imageLoader.loadImage(linkedIn.data.profile.pictureUrl, "profile.png", 30, 30);
	accountManager.getAccount(linkedIn);
end

------------------------------------------

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