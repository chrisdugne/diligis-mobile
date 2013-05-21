-----------------------------------------------------------------------------------------
--
-- Profile.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local profile

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )
	profile = display.newGroup()
end
	
-----------------------------------------------------------------------------------------

function scene:refreshScene(linkedinUID, back)
	viewManager.setupView(self.view);
	viewManager.addCustomButton("images/buttons/leftArrow.png", back);
	self:buildProfile(linkedinUID);
end
	
-----------------------------------------------------------------------------------------

function scene:buildProfile(linkedinUID)
	linkedIn.getProfiles({linkedinUID}, function() self:drawProfile(linkedinUID) end) 
end

function scene:drawProfile(linkedinUID)

	----------------------

	utils.emptyGroup(profile)
	
	----------------------

	imagesManager.drawImage(
		profile, 
		linkedIn.data.people[linkedinUID].pictureUrl, 
		display.contentCenterX, 100, 
		IMAGE_CENTER, 1
	)
	
	----------------------

	local name = linkedIn.data.people[linkedinUID].firstName .. " " .. linkedIn.data.people[linkedinUID].lastName
	local nameDisplay = display.newText( name, 0, 0, native.systemFontBold, 28 )
	nameDisplay:setTextColor( 0 )
	nameDisplay.x = display.contentWidth * 0.5
	nameDisplay.y = 200
	
	profile:insert( nameDisplay )

	----------------------

	local title = linkedIn.data.people[linkedinUID].headline .. " (" .. linkedIn.data.people[linkedinUID].industry .. ")"
	local titleDisplay = display.newText( title, 0, 0, native.systemFont, 16 )
	titleDisplay:setTextColor( 0 )
	titleDisplay.x = display.contentWidth * 0.5
	titleDisplay.y = 300

	profile:insert( titleDisplay )

	----------------------
	
	self.view:insert( profile )

	----------------------

end


-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	if event.params then
   	self:refreshScene(event.params.linkedinUID, event.params.back);
	end
	
	profile.x = -display.contentWidth * 1.5
	transition.to( profile,  { x = 0 , time = 400, transition = easing.outExpo } )
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