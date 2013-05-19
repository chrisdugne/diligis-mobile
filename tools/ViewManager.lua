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
	{ 23, 55, 94, 110 }, 
	{ 23, 55, 94, 255 }, "down" )

	-- Create toolbar to go at the top of the screen
	local titleBar = display.newRect( 0, 0, display.contentWidth, 32 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5
	header:insert( titleBar )
	header.titleBar = titleBar

	-- create embossed text to go on toolbar
	local titleText = display.newText( "Diligis", 0, 0, native.systemFont, 20 )
	titleText:setReferencePoint( display.CenterReferencePoint )
	titleText:setTextColor( 255 )
	titleText.x = 160
	titleText.y = titleBar.y

	header:insert( titleText )
	header.titleText = titleText

	--- home button
	addHomeButton(showMenuCustomAction)
	
	--------------------------------
	-- linkedin logout
	
	local logoutButton = ui.newButton{
		default		= "images/buttons/home.png", 
		over			= "images/buttons/home.png", 
		onRelease	= function() accountManager.logout() hideMenu() if (showMenuCustomAction) then showMenuCustomAction() end end, 
		x 				= 250,
		y 				= titleBar.y
	}
	
	header:insert( logoutButton )
	header.logoutButton = logoutButton

	--------------------------------
	-- tripit logout
	local tripitLogoutButton = ui.newButton{
		default		= "images/buttons/home.png", 
		over			= "images/buttons/home.png", 
		onRelease	= function() tripit.logout() hideMenu() if (showMenuCustomAction) then showMenuCustomAction() end end, 
		x 				= 220,
		y 				= titleBar.y
	}
	
	header:insert( tripitLogoutButton )
	header.tripitLogoutButton = tripitLogoutButton
	
	--
	--	--- top logo
--	local logo = display.newImage(view, "images/logos/top.logo.png" )
--	logo.x = display.contentWidth/2
--	logo.y = titleBar.y

	-- linkedin picture
	local profileImage = imagesManager.drawImage(view, linkedIn.data.profile.pictureUrl, display.contentWidth - 40, 0, IMAGE_TOP_LEFT, 0.4)
	
	header:insert( profileImage )
	header.tripitLogoutButton = profileImage
	
	showHeader()
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

	--- trips button

	local openTripsAction = function() return router.openTrips() end

	local tripsText = display.newText( "Trips", 160, 130, native.systemFont, 20 )
	tripsText:setReferencePoint( display.CenterReferencePoint )
	tripsText:setTextColor( 000 )
	tripsText:addEventListener("tap", openTripsAction)
	menu:insert( tripsText )

	local tripsButton = ui.newButton{
		default="images/buttons/trips.medium.png", 
		over="images/buttons/trips.medium.png", 
		onRelease=openTripsAction, 
		x = 90,
		y = 140,
	}

	menu:insert( tripsButton )
	menu.tripsButton = tripsButton;

	--- stream button

	local openStreamAction = function() return router.openStream(true) end
	
	local streamText = display.newText( "Stream", 160, 230, native.systemFont, 20 )
	streamText:setReferencePoint( display.CenterReferencePoint )
	streamText:setTextColor( 000 )
	streamText:addEventListener("tap", openStreamAction)
	menu:insert( streamText )
	
	local streamButton = ui.newButton{
		default		= "images/buttons/find.medium.png", 
		over			= "images/buttons/find.medium.png", 
		onRelease	= openStreamAction, 
		x 				= 90,
		y 				= 240,
	}

	menu:insert( streamButton )
	menu.streamButton = streamButton;

	--- messages button
--
--	local openMessagesAction = function() return router.openMessages() end
--	 
--	local messagesText = display.newText( "Messages", 160, 330, native.systemFont, 20 )
--	messagesText:setReferencePoint( display.CenterReferencePoint )
--	messagesText:setTextColor( 000 )
--	messagesText:addEventListener("tap", openMessagesAction)
--	menu:insert( messagesText )
--	
--	local messagesButton = ui.newButton{
--		default="images/buttons/messages.medium.png", 
--		over="images/buttons/messages.medium.png", 
--		onRelease=openMessagesAction, 
--		x = 90,
--		y = 340,
--	}
--
--	menu:insert( messagesButton )
--	menu.messagesButton = messagesButton;
	
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
	end
	
	local newButton = ui.newButton{
		default		= image, 
		over			= image, 
		onRelease	= pushButton, 
		x 				= 25,
		y 				= header.titleBar.y
	}
	
	for i in pairs(header.buttons) do
   	transition.to( 
   		header.buttons[i], { 
      		x 				= header.buttons[i].x + 40*i, 
      		time 			= 400, 
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


