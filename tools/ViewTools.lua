-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function drawHeader(group)

	--- reset
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	group:insert( bg )

	--- header background
	-- The gradient used by the title bar
	local titleGradient = graphics.newGradient( 
	{ 23, 55, 94, 110 }, 
	{ 23, 55, 94, 255 }, "down" )

	-- Create toolbar to go at the top of the screen
	local titleBar = display.newRect( 0, 0, display.contentWidth, 32 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5
	group:insert( titleBar )

	-- create embossed text to go on toolbar
	local titleText = display.newText( "Diligis", 0, 0, native.systemFont, 20 )
	titleText:setReferencePoint( display.CenterReferencePoint )
	titleText:setTextColor( 255 )
	titleText.x = 160
	titleText.y = titleBar.y
	group:insert( titleBar )

	--	local bgheader = display.newRect( 0, 0, display.contentWidth, (display.contentHeight)*(15/100) )
	--	bgheader:setFillColor( 23,55,94 )

	---- pour les dimensions de lecran....adapter a chaque device.... : http://developer.coronalabs.com/reference/index/systemgetinfo
	--- home button
	local backToAction = function() return router.openHome() end;
	local homeButton = ui.newButton{
		default="images/buttons/home.png", 
		over="images/buttons/home.png", 
		onRelease=backToAction, 
		--		x = (display.contentWidth)*(15/100), y = (display.contentHeight)*(10/100)
		x = 25,
		y = titleBar.y
	}
	group:insert( homeButton )
	
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
	group:insert( logoutButton )

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
	group:insert( tripitLogoutButton )
	
	--
	--	--- top logo
--	local logo = display.newImage(group, "images/logos/top.logo.png" )
--	logo.x = display.contentWidth/2
--	logo.y = titleBar.y

	-- linkedin picture
	local profileImage = imagesManager.drawImage(group, linkedIn.data.profile.pictureUrl, display.contentWidth - 40, 0, IMAGE_TOP_LEFT, 0.4)
end

function drawLoadingSpinner(group)

	-- Create a spinner widget
	local spinner = widget.newSpinner
	{
		left = 274,
		top = 75,
	}
	group:insert( spinner )

	-- Start the spinner animating
	spinner:start()

end
