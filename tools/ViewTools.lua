-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function drawHeader(group)
	
	--- reset
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	
	--- header background
	local bgheader = display.newRect( 0, 0, display.contentWidth, (display.contentHeight)*(15/100) )
	bgheader:setFillColor( 23,55,94 )

	---- pour les dimensions de lecran....adapter a chaque device.... : http://developer.coronalabs.com/reference/index/systemgetinfo
	--- home button
	local backToAction = function() return router.openHome() end;
	local homeButton = ui.newButton{
		default="images/buttons/home.png", 
		over="images/buttons/home.png", 
		onRelease=backToAction, 
		x = (display.contentWidth)*(15/100), y = (display.contentHeight)*(10/100)
	}
	
	--- top logo
	local logo = display.newImage( "images/logos/top.logo.png" )
	logo.x = display.contentWidth/2
	logo.y = (display.contentHeight)*(10/100)
	
	--- insert all
	group:insert( bg )
	group:insert( bgheader )
	group:insert( logo )
	group:insert( homeButton )
	
end