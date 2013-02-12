-----------------------------------------------------------------------------------------
--
-- router.lua
--
-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

function openTopHome()
	storyboard.gotoScene( "views.tophome" )
end

---------------------------------------------

function openHome()
	storyboard.gotoScene( "views.home" )
end

---------------------------------------------

function openTrips()
	storyboard.gotoScene( "views.trips" )
end