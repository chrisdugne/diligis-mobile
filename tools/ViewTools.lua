-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function drawHeader(group)

	--- reset
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )

	--- header background
	-- The gradient used by the title bar
	local titleGradient = graphics.newGradient( 
	{ 189, 203, 220, 255 }, 
	{ 89, 116, 152, 255 }, "down" )

	-- Create toolbar to go at the top of the screen
	local titleBar = display.newRect( 0, 0, display.contentWidth, 32 )
	titleBar.y = display.statusBarHeight + ( titleBar.contentHeight * 0.5 )
	titleBar:setFillColor( titleGradient )
	titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

	-- create embossed text to go on toolbar
	--	local titleText = display.newEmbossedText( "Diligis", 0, 0, native.systemFontBold, 20 )
	--	titleText:setReferencePoint( display.CenterReferencePoint )
	--	titleText:setTextColor( 255 )
	--	titleText.x = 160
	--	titleText.y = titleBar.y

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
	--
	--	--- top logo
	local logo = display.newImage( "images/logos/top.logo.png" )
	--	logo.x = display.contentWidth/2
	--	logo.y = (display.contentHeight)*(10/100)
	logo.x = 160
	logo.y = titleBar.y
	
	-- linkedin picture
	if(accountManager.user.pictureUrl ~= nil) then
		imagesManager.drawImage(group, accountManager.user.pictureUrl, display.contentWidth - 20, 10, 0.6)
	end

	--- insert all
	group:insert( bg )
	--	group:insert( bgheader )
	group:insert( titleBar )
	--	group:insert( titleText )
	--	group:insert( logo )
	group:insert( homeButton )

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
