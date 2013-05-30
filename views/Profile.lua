-----------------------------------------------------------------------------------------
--
-- Profile.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local profile
local webView
local back

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

function scene:refreshScene(linkedinUID, fromView)
	back = fromView
	viewManager.setupView(self.view, backToDiligis);
	viewManager.addCustomButton("images/buttons/leftArrow.png", backToDiligis);
	self:buildProfile(linkedinUID);

end

-----------------------------------------------------

function backToDiligis()
	webView:removeSelf()
	webView = nil;
	back()
end

-----------------------------------------------------------------------------------------

function scene:buildProfile(linkedinUID)
	linkedIn.getProfiles({linkedinUID}, function() self:drawProfile(linkedinUID) end) 
end

function scene:drawProfile(linkedinUID)

	----------------------

	utils.emptyGroup(profile)

	----------------------

	webView = native.newWebView( display.screenOriginX, display.screenOriginY + HEADER_HEIGHT , display.contentWidth, display.contentHeight - HEADER_HEIGHT )
	webView:request( linkedIn.data.people[linkedinUID].siteStandardProfileRequest.url )

--	imagesManager.drawImage(
--   	profile, 
--   	linkedIn.data.people[linkedinUID].pictureUrl, 
--   	display.contentCenterX, 100, 
--   	IMAGE_CENTER, 1,
--   	false, 
--   	function() self:drawTextsAndButtons(linkedinUID) end
--	)
end

function scene:drawTextsAndButtons(linkedinUID)
	----------------------

	local name = linkedIn.data.people[linkedinUID].firstName .. " " .. linkedIn.data.people[linkedinUID].lastName
	local nameDisplay = display.newText( name, 0, 0, native.systemFontBold, 14 )
	nameDisplay:setTextColor( 0 )
	nameDisplay.x = display.contentWidth * 0.5
	nameDisplay.y = 200

	profile:insert( nameDisplay )

	----------------------

	local title = linkedIn.data.people[linkedinUID].headline
	local titleDisplay = display.newText( title, 0, 0, native.systemFont, 12 )
	titleDisplay:setTextColor( 0 )
	titleDisplay.x = display.contentWidth * 0.5
	titleDisplay.y = 260

	profile:insert( titleDisplay )
	
	----------------------

	local industry = linkedIn.data.people[linkedinUID].industry
	local industryDisplay = display.newText( "(" .. linkedIn.data.people[linkedinUID].industry .. ")", 0, 0, native.systemFont, 12 )
	industryDisplay:setTextColor( 0 )
	industryDisplay.x = display.contentWidth * 0.5
	industryDisplay.y = 280

	profile:insert( industryDisplay )

	----------------------
	--- linkedin logout

	if(accountManager.user.linkedinUID == linkedinUID) then
   	local logoutButton = widget.newButton{
   		defaultFile	= "images/buttons/logout.png", 
   		overFile		= "images/buttons/logout.png", 
   		onRelease	= function() 
   			accountManager.logout()
				analytics.event("Navigation", "logout")  
   		end, 
   	}
   
   	logoutButton.x = display.contentWidth * 0.5
   	logoutButton.y = 450
   
   	profile:insert( logoutButton )
   end

	--	--------------------------------
	--	-- tripit logout
	--
	--	local tripitLogoutButton = widget.newButton{
	--		defaultFile	= "images/buttons/home.png", 
	--		overFile		= "images/buttons/home.png", 
	--		onRelease	= function() tripit.logout() hideMenu() if (showMenuCustomAction) then showMenuCustomAction() end end, 
	--   }
	--   
	--   tripitLogoutButton.x = 220
	--   tripitLogoutButton.y = titleBar.y
	--	
	--		profile:insert( tripitLogoutButton )
	--	


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