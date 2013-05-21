-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function setupView(view, showMenuCustomAction)
	reset			(view)
	drawHeader	(view, showMenuCustomAction)
	drawMenu		(view)
end

------------------------------------------------------------------------------------------

function reset(view)
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	view:insert( bg )
end

------------------------------------------------------------------------------------------
-- 																										HEADER
------------------------------------------------------------------------------------------

function drawHeader(view, showMenuCustomAction)

	utils.emptyGroup(header)
	header.x = 0
	header.y = 0
	header.buttons = {}
	
	--- header background
	-- The gradient used by the title bar
	local titleGradient = graphics.newGradient( 
	{ 23, 23, 23, 6 }, 
	{ 45, 45, 45, 144 }, "down" )

	-- Create toolbar to go at the top of the screen
	local titleBar = display.newRect( 0, 0, display.contentWidth, 32 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5
	header:insert( titleBar )
	header.titleBar = titleBar

	--- home button
	addHomeButton(showMenuCustomAction)
	
	--	--- top logo
	local logo = display.newImage(view, "images/logos/d_logo_small.png" )
	logo.x = 2*display.contentWidth/3
	logo.y = titleBar.y + 3
	
	header:insert( logo )
	header.profilelogoImage = logo

	-- linkedin picture
	
	imagesManager.drawImage(
		header, 
		linkedIn.data.profile.pictureUrl, 
		display.contentWidth - 40, 0, 
		IMAGE_TOP_LEFT, 0.4,
		false,
		function(image)
			local openMyProfile = function() hideMenu() router.displayProfile(accountManager.user.linkedinUID) end
      	image:addEventListener("tap", openMyProfile)
      	header.image = image
      	
      	showHeader()
		end
	)
	
	
end

---------------------------------------------

function showHeader()
	transition.to( header,  { alpha = 1 , time = 400, transition = easing.outExpo } )
end

function removeHeader()
	transition.to( header,  { alpha = 0 , time = 400, transition = easing.outExpo } )
end

------------------------------------------------------------------------------------------
-- 																								MENU
------------------------------------------------------------------------------------------

function drawMenu(view)

	utils.emptyGroup(menu)
	menu.x = 0
	menu.y = display.contentHeight + display.contentHeight * 0.5
	
	local bg = display.newRect( display.screenOriginX, display.screenOriginY + 38, display.contentWidth, display.contentHeight - 38 )
	bg:setFillColor( 255 )
	menu:insert( bg )

	--- stream button

	local openStreamAction = function() return router.openStream() end
	
	local streamText = display.newText( "Stream", 160, 130, native.systemFont, 20 )
	streamText:setReferencePoint( display.CenterReferencePoint )
	streamText:setTextColor( 000 )
	streamText:addEventListener("tap", openStreamAction)
	menu:insert( streamText )
	
	local streamButton = widget.newButton{
		defaultFile	= "images/buttons/find.medium.png", 
		overFile		= "images/buttons/find.medium.png", 
		onRelease	= openStreamAction
   }
   
   streamButton.x = 90
   streamButton.y = 140

	menu:insert( streamButton )
	menu.streamButton = streamButton;

	--- trips button

	local openTripsAction = function() return router.openTrips() end

	local tripsText = display.newText( "Trips", 160, 230, native.systemFont, 20 )
	tripsText:setReferencePoint( display.CenterReferencePoint )
	tripsText:setTextColor( 000 )
	tripsText:addEventListener("tap", openTripsAction)
	menu:insert( tripsText )

	local tripsButton = widget.newButton{
		defaultFile	= "images/buttons/trips.medium.png", 
		overFile		= "images/buttons/trips.medium.png", 
		onRelease	= openTripsAction
   }
   
   tripsButton.x = 90
   tripsButton.y = 240
   
	menu:insert( tripsButton )
	menu.tripsButton = tripsButton;
	
end

---------------------------------------------

function toggleMenu()

	menu:toFront()

	if(menu.y == 0) then
		hideMenu()
	else
		showMenu()
	end
end

function showMenu()
	transition.to( menu, { 
		y 				= 0, 
		time 			= 400, 
		transition 	= easing.outExpo 
	})
end

function hideMenu()
	transition.to( menu, { 
		y 				= display.contentHeight + 1.5, 
		time 			= 250, 
		transition 	= easing.inExpo 
	})
end

------------------------------------------------------------------------------
-- 																					BUTTONS
------------------------------------------------------------------------------

function addHomeButton(showMenuCustomAction)
	addCustomButton("images/buttons/home2.png", toggleMenu, showMenuCustomAction, true)
end

---------------------------------------------

function addCustomButton(image, action, showMenuCustomAction, isShowMenuButton)

	local pushButton = function() 
		action()
		if not isShowMenuButton then hideMenu() end 
		if isShowMenuButton and showMenuCustomAction then showMenuCustomAction() end 

   	--- analytics
		if isShowMenuButton then analytics.event("Navigation", "showMenu") end 
   	--- 
	end
	
	local newButton = widget.newButton{
		defaultFile	= image, 
		overFile		= image, 
		onRelease	= pushButton
   }
   
   newButton.x = 25
   newButton.y = header.titleBar.y
	
	for i in pairs(header.buttons) do
   	transition.to( 
   		header.buttons[i], { 
      		x 				= header.buttons[i].x + 40*i, 
      		time 			= 40, 
      		transition 	= easing.outExpo 
   		}
   	)
	end

	header:insert( newButton )	
	table.insert(header.buttons, 1, newButton)
end

---------------------------------------------

function removeAllButtons()
	for i in pairs(header.buttons) do
   	header.buttons[i]:removeSelf()
	end
	
	addHomeButton()
end



------------------------------------------------------------------------------
-- 																					SPINNER
------------------------------------------------------------------------------

function drawLoadingSpinner(view)

	-- Create a spinner widget
	local spinner = widget.newSpinner
	{
		left = 274,
		top = 75,
	}
	view:insert( spinner )

	-- Start the spinner animating
	spinner:start()

end


