-----------------------------------------------------------------------------------------
--
-- trips.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local tripit = require("libs.social.Tripit")
--local tableView = require("tools.tableView")

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	--- reset + header
	viewTools.drawHeader(group);

	--- 'sync with' text
	local syncwith = display.newRetinaText( "sync with", 0, 0, native.systemFont, 21 )
	syncwith:setTextColor( 0 )	
	syncwith:setReferencePoint( display.CenterReferencePoint )
	syncwith.x = display.contentWidth * 0.17
	syncwith.y = display.contentHeight/4

	---- Add demo button to screen
	tripit.init();
	local importFromTripit = function() return tripit.authorise(tripitAuthenticated) end;
	tripitButton = ui.newButton{default="images/buttons/tripit.png", over="images/buttons/tripit.png", onRelease=importFromTripit, x = display.contentWidth * 0.5, y = display.contentHeight/4 + 20  }


	----------------------

	local tripList = {}
	local user = accountManager.user;

	for i in pairs(user.trips) do
		local tripName = display.newRetinaText( user.trips[i].displayName, 0, 0, native.systemFont, 13 )
		tripName:setTextColor( 0 )	
		tripName:setReferencePoint( display.CenterReferencePoint )
		tripName.x = display.contentWidth * 0.17
		tripName.y = 200 + i*25
		
		group:insert(tripName);
	end
	
	
--	
--	for i in pairs(user.trips) do
--		local data = {}
--		data.title = user.trips[i].displayName
--		data.subtitle = user.trips[i].country
--		data.image = user.trips[i].imageUrl
--		table.insert(tripList, data)
--	end
--
--	local topBoundary = display.screenOriginY + 140
--	local bottomBoundary = display.screenOriginY + 0
--
--	-- create the list of items
--	myList = tableView.newList{
--		data=tripList, 
--		default="listItemBg.png",
--		--default="listItemBg_white.png",
--		over="listItemBg_over.png",
----		onRelease=listButtonRelease,
--		top=topBoundary,
--		bottom=bottomBoundary,
--		--backgroundColor={ 255, 255, 255 },  --commented this out because we're going to add it down below
--		callback = function( row )
--			local g = display.newGroup()
--
--			local img = display.newImage(row.image)
--			g:insert(img)
--			img.x = math.floor(img.width*0.5 + 6)
--			img.y = math.floor(img.height*0.5) 
--
--			local title =  display.newText( row.title, 0, 0, native.systemFontBold, 14 )
--			title:setTextColor(0, 0, 0)
--			--title:setTextColor(255, 255, 255)
--			g:insert(title)
--			title.x = title.width*0.5 + img.width + 6
--			title.y = 30
--
--			local subtitle =  display.newText( row.subtitle, 0, 0, native.systemFont, 12 )
--			subtitle:setTextColor(80,80,80)
--			--subtitle:setTextColor(180,180,180)
--			g:insert(subtitle)
--			subtitle.x = subtitle.width*0.5 + img.width + 6
--			subtitle.y = title.y + title.height + 6
--
--			return g   
--		end 
--	}

	--- all objects must be added to group (e.g. self.view)
	group:insert( syncwith )
	group:insert( tripitButton )
end


function tripitAuthenticated()
	print ( "tripitAuthenticated" )

	local trips = {}

	for i in pairs(tripit.data.trips) do
		local trip = {
			displayName = tripit.data.trips[i].display_name.value,
			id = tripit.data.trips[i].id.value,
			startDate = tripit.data.trips[i].start_date.value,
			endDate = tripit.data.trips[i].end_date.value,
			country = tripit.data.trips[i].PrimaryLocationAddress.country.value,
			city = tripit.data.trips[i].PrimaryLocationAddress.city.value,
			latitude = tripit.data.trips[i].PrimaryLocationAddress.latitude.value,
			longitude = tripit.data.trips[i].PrimaryLocationAddress.longitude.value,
			imageUrl = tripit.data.trips[i].image_url.value,
			lastModified = tripit.data.trips[i].last_modified.value
		}

		table.insert(trips, trip)
	end

	accountManager.user.trips = trips
	accountManager.refreshTrips()
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)

end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)

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