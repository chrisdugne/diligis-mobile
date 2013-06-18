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

function scene:refreshScene(linkedinUID, userUID, fromView)
	back = fromView
	viewManager.setupView(self.view, backToDiligis);
	viewManager.addCustomButton("images/buttons/leftArrow.png", backToDiligis);
	self:buildProfile(linkedinUID, userUID);
end

-----------------------------------------------------

function backToDiligis()
	if(webView) then
		webView:removeSelf()
		webView = nil;
	end
	back()
end

-----------------------------------------------------------------------------------------

function scene:buildProfile(linkedinUID, userUID)
	if(not accountManager.user.isConnected) then 
		if(userUID == accountManager.user.uid) then
			self:drawDiligisProfile(accountManager.user, true, false)
		else
			accountManager.getUser(userUID, function (user) self:drawDiligisProfile(user, true, linkedinUID == "none") end)
		end
	elseif (linkedinUID == "none") then
		self:drawDiligisProfile(accountManager.user, false, true)
	else
		linkedIn.getProfiles({linkedinUID}, function() self:drawProfile(linkedinUID) end) 
	end
end

-----------------------------------------------------------------------------------------

function scene:drawDiligisProfile(user, userIsNotConnected, otherUserIsNotLinked)

	----------------------

	utils.emptyGroup(profile)

	----------------------
	
	imagesManager.drawImage(
	profile, 
	user.pictureUrl, 
	60, 100, 
	IMAGE_CENTER, 1,
	false, 
	function(image)  
		--- simple Diligis profile
		local senderName = display.newText( user.name, 0, 0, 270, 50, native.systemFontBold, 14 )
		senderName:setTextColor( 0 )
		senderName.x = image.x + 180
		senderName.y = image.y
		profile:insert(senderName)

		local senderProfile = display.newText( user.headline, 0, 0, 270, 50, native.systemFont, 14 )
		senderProfile:setTextColor( 0 )
		senderProfile.x = image.x + 180
		senderProfile.y = image.y + 30
		profile:insert(senderProfile)

		if(userIsNotConnected) then
		
      	local signinText = "Sign in with LinkedIn for a complete experience !"
      	local signinTextDisplay = display.newText( signinText, display.contentWidth * 0.5 - 80, display.contentHeight/2, display.contentWidth/2, 200, native.systemFontBold, 14 )
      	signinTextDisplay:setTextColor( 0 )
      
      	profile:insert( signinTextDisplay )
	
   		--- in button
   
   		local signInButton = widget.newButton{
   			defaultFile	= "images/buttons/linkedin.medium.png", 
   			overFile		= "images/buttons/linkedin.medium.png", 
   			onRelease	= signIn,
   			alpha 		= 1
   		}
   
   		signInButton.x = 2*display.contentWidth/3
   		signInButton.y =  3*display.contentHeight/4+20
   		profile:insert(signInButton)
   	end
		

		if(otherUserIsNotLinked) then
		
      	local noLinkedText = "This user is not linked with LinkedIn yet"
      	local noLinkedDisplay = display.newText( noLinkedText, display.contentWidth * 0.5 - 80, display.contentHeight/2, display.contentWidth/2, 200, native.systemFontBold, 14 )
      	noLinkedDisplay:setTextColor( 0 )
      
      	profile:insert( noLinkedDisplay )
   	end
		
   	----------------------
   
   	self.view:insert( profile )
   
   	----------------------
	end
	)
end


function scene:drawProfile(linkedinUID)

	----------------------

	utils.emptyGroup(profile)

	----------------------

	if(linkedIn.data.people[linkedinUID].siteStandardProfileRequest) then
		webView = native.newWebView( display.screenOriginX, display.screenOriginY + HEADER_HEIGHT , display.contentWidth, display.contentHeight - HEADER_HEIGHT )
		webView:request( linkedIn.data.people[linkedinUID].siteStandardProfileRequest.url )
	else
   	imagesManager.drawImage(
      	profile, 
      	accountManager.user.pictureUrl, 
      	60, 100, 
      	IMAGE_CENTER, 1,
      	false, 
      	function(image) self:drawTextsAndButtons(image, linkedinUID) end
   	)
	end

	----------------------

	self.view:insert( profile )

	----------------------
end

function scene:drawTextsAndButtons(image, linkedinUID)

	if(linkedinUID) then 
   	local privateText = "This person has asked LinkedIn not to tell any information."
   	local privateDisplay = display.newText( privateText, display.contentWidth * 0.5 - 80, 200, 200, 200, native.systemFontBold, 14 )
   	privateDisplay:setTextColor( 0 )
   
   	profile:insert( privateDisplay )
   else
  		--- simple Diligis profile
   	local senderName = display.newText( accountManager.user.name, 0, 0, 270, 50, native.systemFontBold, 14 )
   	senderName:setTextColor( 0 )
   	senderName.x = image.x + 180
   	senderName.y = image.y
   	profile:insert(senderName)
   
   	local senderProfile = display.newText( accountManager.user.headline, 0, 0, 270, 50, native.systemFont, 14 )
   	senderProfile:setTextColor( 0 )
   	senderProfile.x = image.x + 180
   	senderProfile.y = image.y + 30
   	profile:insert(senderProfile)
		
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
   	profile:insert(signInButton)
      
  	end
end

------------------------------------------

function signIn()

	--- analytics
	analytics.event("LinkedIn", "signIn") 
	--- 
	
	accountManager.linkedInConnect()
	
--	enterSceneBeforeTimerComplete = false
--	timer.performWithDelay( 3000, toLongLinkedin )

end


---
--local enterSceneBeforeTimerComplete
--function toLongLinkedin( event )
----	if(not enterSceneBeforeTimerComplete) then
----		transition.to( cancelButton, { alpha = 1 } )
----	end		
--end
      
  	
----------------------------------------------------------------------------------------------------------------------
--  	  	

--	local name = linkedIn.data.people[linkedinUID].firstName .. " " .. linkedIn.data.people[linkedinUID].lastName
--	local nameDisplay = display.newText( name, 0, 0, native.systemFontBold, 14 )
--	nameDisplay:setTextColor( 0 )
--	nameDisplay.x = display.contentWidth * 0.5
--	nameDisplay.y = 200
--
--	profile:insert( nameDisplay )
--
--	----------------------
--
--	local title = linkedIn.data.people[linkedinUID].headline
--	local titleDisplay = display.newText( title, 0, 0, native.systemFont, 12 )
--	titleDisplay:setTextColor( 0 )
--	titleDisplay.x = display.contentWidth * 0.5
--	titleDisplay.y = 260
--
--	profile:insert( titleDisplay )
--	
--	----------------------
--
--	local industry = linkedIn.data.people[linkedinUID].industry
--	local industryDisplay = display.newText( "(" .. linkedIn.data.people[linkedinUID].industry .. ")", 0, 0, native.systemFont, 12 )
--	industryDisplay:setTextColor( 0 )
--	industryDisplay.x = display.contentWidth * 0.5
--	industryDisplay.y = 280
--
--	profile:insert( industryDisplay )
--
--	----------------------
--	--- linkedin logout
--
--	if(accountManager.user.linkedinUID == linkedinUID) then
--   	local logoutButton = widget.newButton{
--   		defaultFile	= "images/buttons/logout.png", 
--   		overFile		= "images/buttons/logout.png", 
--   		onRelease	= function() 
--   			accountManager.logout()
--				analytics.event("Navigation", "logout")  
--   		end, 
--   	}
--   
--   	logoutButton.x = display.contentWidth * 0.5
--   	logoutButton.y = 450
--   
--   	profile:insert( logoutButton )
--   end

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
--
--
--	----------------------
--
--	self.view:insert( profile )
--
--	----------------------
--
--end


-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )

	if event.params then
		self:refreshScene(
			event.params.linkedinUID, 
			event.params.userUID, 
			event.params.back
		);
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