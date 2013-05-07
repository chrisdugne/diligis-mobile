-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function setupView(view)
	reset			(view)
	drawHeader	(view)
	drawMenu		(view)
end

------------------------------------------------------------------------------------------

function reset(view)
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	view:insert( bg )
end

------------------------------------------------------------------------------------------

function drawHeader(view)

	--- header background
	-- The gradient used by the title bar
	local titleGradient = graphics.newGradient( 
	{ 23, 55, 94, 110 }, 
	{ 23, 55, 94, 255 }, "down" )

	-- Create toolbar to go at the top of the screen
	local titleBar = display.newRect( 0, 0, display.contentWidth, 32 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5
	view:insert( titleBar )

	-- create embossed text to go on toolbar
	local titleText = display.newText( "Diligis", 0, 0, native.systemFont, 20 )
	titleText:setReferencePoint( display.CenterReferencePoint )
	titleText:setTextColor( 255 )
	titleText.x = 160
	titleText.y = titleBar.y
	view:insert( titleBar )

	--	local bgheader = display.newRect( 0, 0, display.contentWidth, (display.contentHeight)*(15/100) )
	--	bgheader:setFillColor( 23,55,94 )

	---- pour les dimensions de lecran....adapter a chaque device.... : http://developer.coronalabs.com/reference/index/systemgetinfo
	--- home button
	local toggleMenu = function() return router.toggleMenu() end;
	local homeButton = ui.newButton{
		default		= "images/buttons/home.png", 
		over			= "images/buttons/home.png", 
		onRelease	= toggleMenu, 
		x 				= 25,
		y 				= titleBar.y
	}
	view:insert( homeButton )
	
	--------------------------------
	-- linkedin logout
	local logoutAction = function() return accountManager.logout() end;
	local logoutButton = ui.newButton{
		default="images/buttons/home.png", 
		over="images/buttons/home.png", 
		onRelease=logoutAction, 
		x = 250,
		y = titleBar.y
	}
	view:insert( logoutButton )

	--------------------------------
	-- tripit logout
	local tripitLogoutAction = function() return tripit.logout() end;
	local tripitLogoutButton = ui.newButton{
		default="images/buttons/home.png", 
		over="images/buttons/home.png", 
		onRelease=tripitLogoutAction, 
		x = 220,
		y = titleBar.y
	}
	view:insert( tripitLogoutButton )
	
	--
	--	--- top logo
--	local logo = display.newImage(view, "images/logos/top.logo.png" )
--	logo.x = display.contentWidth/2
--	logo.y = titleBar.y

	-- linkedin picture
	local profileImage = imagesManager.drawImage(view, linkedIn.data.profile.pictureUrl, display.contentWidth - 40, 0, IMAGE_TOP_LEFT, 0.4)
end

------------------------------------------------------------------------------------------

function drawMenu(view)

	utils.emptyGroup(menu)
	menu.x = display.contentWidth + display.contentWidth * 0.5
	menu.y = 0
	
	local bg = display.newRect( display.screenOriginX, display.screenOriginY + 38, display.contentWidth, display.contentHeight - 38 )
	bg:setFillColor( 255 )
	menu:insert( bg )

	local t = display.newText( "Menu", 0, 40, native.systemFont, 20 )
	t:setReferencePoint( display.CenterReferencePoint )
	t:setTextColor( 000 )
	menu:insert( t )
	
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
	
	view:insert( menu )
end

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
