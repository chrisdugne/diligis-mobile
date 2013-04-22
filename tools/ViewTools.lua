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


function drawList(group)

	--Text to show which item we selected
	local itemSelected = display.newText( "You selected item ", 0, 0, native.systemFontBold, 28 )
	itemSelected:setTextColor( 0 )
	itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
	itemSelected.y = display.contentCenterY
	group:insert( itemSelected )

	-- Forward reference for our back button & tableview
	local backButton, list

	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local row = event.row

		local rowTitle = display.newText( row, "List item " .. row.index, 0, 0, native.systemFontBold, 16 )
		rowTitle:setTextColor( 0 )
		rowTitle.x = row.x - ( row.contentWidth * 0.5 ) + ( rowTitle.contentWidth * 0.5 )
		rowTitle.y = row.contentHeight * 0.5

		local rowArrow = display.newImage( row, "images/buttons/rowArrow.png", false )
		rowArrow.x = row.x + ( row.contentWidth * 0.5 ) - rowArrow.contentWidth
		rowArrow.y = row.contentHeight * 0.5
	end

	-- Hande row touch events
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target

		if "press" == phase then
			print( "Pressed row: " .. row.index )

		elseif "release" == phase then
			-- Update the item selected text
			itemSelected.text = "You selected item " .. row.index

			--Transition out the list, transition in the item selected text and the back button
			transition.to( list, { x = - list.contentWidth, time = 400, transition = easing.outExpo } )
			transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
			transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )

			print( "Tapped and/or Released row: " .. row.index )
		end
	end

	-- Create a tableView
	list = widget.newTableView
	{
		top = 38,
		width = 320, 
		height = 448,
		hideBackground = true,
		maskFile = "mask-320x448.png",
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	}

	--Insert widgets/images into a group
	group:insert( list )


	--Handle the back button release event
	local function onBackRelease()
		--Transition in the list, transition out the item selected text and the back button
		transition.to( list, { x = 0, time = 400, transition = easing.outExpo } )
		transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
		transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	end

	--Create the back button
	backButton = widget.newButton
	{
		width = 298,
		height = 56,
		label = "Back", 
		labelYOffset = - 1,
		onRelease = onBackRelease
	}
	backButton.alpha = 0
	backButton.x = display.contentCenterX
	backButton.y = display.contentHeight - backButton.contentHeight
	group:insert( backButton )

	-- insert rows into list (tableView widget)
	for i = 1, 20 do
		list:insertRow
		{
			height = 72,
			rowColor = 
			{ 
				default = { 255, 255, 255, 0 },
			},
		}
	end


end