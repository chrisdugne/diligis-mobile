-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function drawHeader(group)
	
	--- reset
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	
	--- header
	local bgheader = display.newRect( 0, 0, display.contentWidth, 27 )
	bgheader:setFillColor( 23,55,94 )

	local backToAction = function() return router.openHome() end;
	local homeButton = ui.newButton{
		default="images/buttons/home.png", 
		over="images/buttons/home.png", 
		onRelease=backToAction, 
		x = 12, y = 12
	}
	
	group:insert( bg )
	group:insert( bgheader )
	group:insert( homeButton )
end