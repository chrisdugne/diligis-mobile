-----------------------------------------------------------------------------------------
--
-- TripDiligis.lua
--

-----------------------------------------------------------------------------------------

local scene = storyboard.newScene()
local list
local events

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

--- Called when the scene's view does not exist:
function scene:createScene( event )

end
	
-----------------------------------------------------------------------------------------

function scene:refreshScene()
	viewTools.setupView(self.view);
	self:buildDiligis();
end
	
-----------------------------------------------------------------------------------------

function scene:buildDiligis()

	----------------------

	local backButton = widget.newButton	{
		width = display.contentWidth/3,
		height = 46,
		label = "Back", 
		labelYOffset = - 1,
		onRelease = router.openTrips
	}
	
	backButton.x = display.contentCenterX
	backButton.y = display.contentHeight - backButton.contentHeight
	
	self.view:insert( backButton )
	
	----------------------

	list = widget.newTableView{
		top 				= 38,
		width 			= 320, 
		height			= 448,
		hideBackground = true,
		maskFile 		= "images/masks/mask-320x448.png",
		onRowRender 	= function(event) return self:onRowRender(event) end,
	}

	self.view:insert( list )

	----------------------
	
	events = {}

	if(selectedTrip ~= nil and #selectedTrip.events > 0 ) then
		for i in pairs(selectedTrip.events) do
			if(selectedTrip.events[i].content.type > 0) then
				table.insert(events, selectedTrip.events[i])
   		end
		end
	end

	for i in pairs(events) do
		self:createRow() 
	end
end


-----------------------------------------------------------------------------------------
--- List tools : row creation + touch events
function scene:createRow()
	list:insertRow
	{
		rowHeight = 144,
		rowColor = 
		{ 
			default = { 255, 255, 255, 0 },
		}
	}
end

----------------------
--- Handle row rendering
--	

function scene:onRowRender( event )
	local phase = event.phase
	local row = event.row
	local diligis = events[row.index];

	local icon = display.newImage( "images/buttons/diligis.png", false )
	icon.x = icon.contentWidth/2 + 10
	icon.y = row.height * 0.5
	row:insert(icon)

	local text = display.newText( diligis.content.text, 0, 0, 270, 50, native.systemFont, 14 )
	text:setTextColor( 0 )
	text.x = 205
	text.y = 30
	row:insert(text)

	local travelerName = display.newText( diligis.travelerName, 0, 0, 270, 50, native.systemFontBold, 14 )
	travelerName:setTextColor( 0 )
	travelerName.x = 205
	travelerName.y = 70
	row:insert(travelerName)

	local travelerProfile = display.newText( diligis.travelerProfile, 0, 0, 270, 50, native.systemFont, 14 )
	travelerProfile:setTextColor( 0 )
	travelerProfile.x = 205
	travelerProfile.y = 90
	row:insert(travelerProfile)

	local writeTo = display.newText( "Write a message : ", 0, 0, 270, 50, native.systemFont, 14 )
	writeTo:setTextColor( 0 )
	writeTo.x = 235
	writeTo.y = 120
	row:insert(writeTo)

	local write = function() openWriter(diligis.travelerLinkedinUID, diligis.travelerName, diligis.travelerProfile) end
	local message = display.newImage( "images/icons/messages.icon.png", false )
	message.x = writeTo.x + 50
	message.y = writeTo.y - 15
	message:addEventListener("tap", write)
	row:insert(message)
	
end

function openWriter(linkedinUID, name, profile)
	selectedTraveler = {}
	selectedTraveler.linkedinUID 	= linkedinUID
	selectedTraveler.name 			= name
	selectedTraveler.profile 		= profile
	router.openWriteMessage()
end

-----------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	self:refreshScene();
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