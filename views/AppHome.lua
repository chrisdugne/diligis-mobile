-----------------------------------------------------------------------------------------
--
-- AppHome.lua
--
-----------------------------------------------------------------------------------------

local scene 		= storyboard.newScene()

-----------------------------------------------------------------------------------------

local linkedInImage
local signInButton
local cancelButton
local loadingSpinner

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
	
	--- reset
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	view:insert( bg )
	
	--- logo
	local logo = display.newImage( "images/logos/d_logo.png" )
	logo.x = display.contentWidth/2
	logo.y = display.contentHeight/4
	
	--- sign in text
	local signinText = display.newText( "sign in", 0, 0, native.systemFont, 21 )
	signinText:setTextColor( 0 )	
	signinText:setReferencePoint( display.CenterReferencePoint )
	signinText.x = display.contentWidth * 0.5
	signinText.y = 3*display.contentHeight/4 - 45
		
	--- in button
	local signinAction = function() return signIn() end
	
	signInButton = widget.newButton{
		defaultFile	= "images/buttons/linkedin.medium.png", 
		overFile		= "images/buttons/linkedin.medium.png", 
		onRelease	= signinAction ,
		alpha 		= 1
   }
   
   signInButton.x = display.contentWidth/2
   signInButton.y =  3*display.contentHeight/4+20
	
	--- cancel button
	local cancelAction = function() analytics.event("Navigation", "appHomeCancel")  accountManager.logout() end
	cancelButton = widget.newButton	{
		width = 80,
		height = 40,
		label = "Cancel", 
		labelYOffset = -2,
		onRelease = cancelAction
	}
	
   cancelButton.x = display.contentWidth/2
   cancelButton.y =  3*display.contentHeight/4 - 100
	
	cancelButton.alpha = 0
	view:insert( cancelButton )
   
	-- Create a spinner widget
	loadingSpinner = widget.newSpinner
	{
		left 		= display.contentCenterX - 25,
		top 		= 3*display.contentHeight/4,
		width 	= 50,
		height	= 50,
	}
	loadingSpinner.alpha = 0
	view:insert( loadingSpinner )
	
	--- all objects must be added to group (e.g. self.view)
	view:insert( logo )
	view:insert( signinText )
	view:insert( signInButton )
	
end

------------------------------------------

local enterSceneBeforeTimerComplete
function signIn()

	--- analytics
	analytics.event("Navigation", "signIn") 
	--- 
	
	loadingSpinner:start()
	transition.to( loadingSpinner, { alpha = 1 } )
	transition.to( signInButton, 	 { alpha = 0 } )
	transition.to( cancelButton, 	 { alpha = 0 } )
	accountManager.linkedInConnect()
	
	enterSceneBeforeTimerComplete = false
	timer.performWithDelay( 3000, toLongLinkedin )
end

function toLongLinkedin( event )
	if(not enterSceneBeforeTimerComplete) then
		transition.to( cancelButton, { alpha = 1 } )
	end		
end

------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	loadingSpinner.alpha = 0
	transition.to( cancelButton, { alpha = 0 } )
	transition.to( signInButton, { alpha = 1 } )
	enterSceneBeforeTimerComplete = true
	viewManager.removeHeader()
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