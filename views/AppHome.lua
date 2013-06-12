-----------------------------------------------------------------------------------------
--
-- AppHome.lua
--
-----------------------------------------------------------------------------------------

local scene 		= storyboard.newScene()

-----------------------------------------------------------------------------------------

local EMAIL_DEFAULT_TEXT 		= "Enter your email"
local FIRSTNAME_DEFAULT_TEXT 	= "Enter your firstname"
local LASTNAME_DEFAULT_TEXT 	= "Enter your lastname"
local HEADER_DEFAULT_TEXT 		= "Enter your headline"

-----------------------------------------------------------------------------------------

local linkedInImage
--//local signInButton
--local cancelButton
--local loadingSpinner

local emailField, 		emailOK
local firstNameField, 	firstNameOK
local lastNameField,		lastNameOK
local headlineField, 	headlineOK
local validateButton

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	
end

-----------------------------------------------------------------------------------------

function scene:refreshScene()

	local view = self.view
	
	--- reset
	local bg = display.newRect( display.screenOriginX, display.screenOriginY, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )
	view:insert( bg )
	
	--- logo
	local logo = display.newImage( "images/logos/d_logo.png" )
	logo.x = display.contentWidth/2
	logo.y = display.contentHeight/4
	view:insert( logo )
	
	if(not localData.user.uid) then
		self:createForm()
	else
		self:createUser()
	end
	
	--- sign in text
--	local signinText = display.newText( "sign in", 0, 0, native.systemFont, 21 )
--	signinText:setTextColor( 0 )	
--	signinText:setReferencePoint( display.CenterReferencePoint )
--	signinText.x = display.contentWidth * 0.5
--	signinText.y = 3*display.contentHeight/4 - 45
--		
--	--- in button
--	local signinAction = function() return signIn() end
--	
--	signInButton = widget.newButton{
--		defaultFile	= "images/buttons/linkedin.medium.png", 
--		overFile		= "images/buttons/linkedin.medium.png", 
--		onRelease	= signinAction ,
--		alpha 		= 1
--   }
--   
--   signInButton.x = display.contentWidth/2
--   signInButton.y =  3*display.contentHeight/4+20
--	
--	--- cancel button
--	local cancelAction = function() analytics.event("Navigation", "appHomeCancel")  accountManager.logout() end
--	cancelButton = widget.newButton	{
--		width = 80,
--		height = 40,
--		label = "Cancel", 
--		labelYOffset = -2,
--		onRelease = cancelAction
--	}
--	
--   cancelButton.x = display.contentWidth/2
--   cancelButton.y =  3*display.contentHeight/4 - 100
--	
--	cancelButton.alpha = 0
--	view:insert( cancelButton )
--   
--	-- Create a spinner widget
--	loadingSpinner = widget.newSpinner
--	{
--		left 		= display.contentCenterX - 25,
--		top 		= 3*display.contentHeight/4,
--		width 	= 50,
--		height	= 50,
--	}
--	loadingSpinner.alpha = 0
--	view:insert( loadingSpinner )
--	
--	--- all objects must be added to group (e.g. self.view)
--	view:insert( logo )
--	view:insert( signinText )
--	view:insert( signInButton )
	
end

-------------------------------------------------------------------------------------------------------------
-- WELCOME FORM
-------------------------------------------------------------------------------------------------------------

function scene:createUser()

	local view = self.view
	
	-------------------------
	--- Welcome text
	
	imagesManager.drawImage(
		view, 
		localData.user.pictureUrl, 
		50, display.contentHeight/2, 
		IMAGE_CENTER, 0.7,
		false,
		function(image)
      	
      	local senderName = display.newText( localData.user.name, 0, 0, 270, 50, native.systemFontBold, 14 )
      	senderName:setTextColor( 0 )
      	senderName.x = image.x + 180
      	senderName.y = image.y
      	view:insert(senderName)
      
      	local senderProfile = display.newText( localData.user.headline, 0, 0, 270, 50, native.systemFont, 14 )
      	senderProfile:setTextColor( 0 )
      	senderProfile.x = image.x + 180
      	senderProfile.y = image.y + 30
      	view:insert(senderProfile)
      	
		end
	)

	-------------------------
	
	validateButton = widget.newButton	{
		width = 80,
		height = 40,
		label = "Enter", 
		labelYOffset = -2,
		onRelease = enter
	}
	
   validateButton.x = display.contentWidth/2
   validateButton.y =  5*display.contentHeight/6
	
	view:insert( validateButton )
	
end

function enter()
	analytics.event("Navigation", "appHomeEnter")
   
   if(accountManager.user.linkedinUID and accountManager.user.linkedinUID ~= "none") then
   	accountManager.linkedInConnect(true)
   else
		accountManager.getAccount()
   end
   
end

-------------------------------------------------------------------------------------------------------------
-- WELCOME FORM
-------------------------------------------------------------------------------------------------------------

function scene:createForm()

	local view = self.view
	
	-------------------------
	--- Welcome text
	
	local signinText = display.newText( "Welcome !", 0, 0, native.systemFont, 21 )
	signinText:setTextColor( 0 )	
	signinText:setReferencePoint( display.CenterReferencePoint )
	signinText.x = display.contentWidth * 0.5
	signinText.y = display.contentHeight/2 - 65
	view:insert( signinText )
	
	-------------------------
	
	emailField = native.newTextField( 
   	display.contentWidth * 0.125, 
   	display.contentHeight/2, 
   	display.contentWidth * 0.7
   	, 30 
	)
	emailField:setTextColor( 0 )	
	emailField.align = "center"
	emailField.size = 14
	emailField.text = EMAIL_DEFAULT_TEXT
	emailField:setReferencePoint( display.CenterReferencePoint )
	emailField:addEventListener( "userInput", emailHandler )
	view:insert( emailField )
	
	emailOK = display.newImage( "images/icons/ok.png", false )
	emailOK.x = display.contentWidth - 30
	emailOK.y = emailField.y - 6
	emailOK.alpha = 0
	view:insert(emailOK)

	-------------------------
	
	firstNameField = native.newTextField( 
   	display.contentWidth * 0.125, 
   	display.contentHeight/2 + 40, 
   	display.contentWidth * 0.7
   	, 30 
	)
	firstNameField:setTextColor( 0 )	
	firstNameField.align = "center"
	firstNameField.size = 14
	firstNameField.text = FIRSTNAME_DEFAULT_TEXT
	firstNameField:setReferencePoint( display.CenterReferencePoint )
	firstNameField:addEventListener( "userInput", firstNameHandler )
	view:insert( firstNameField )
	
	firstNameOK = display.newImage( "images/icons/ok.png", false )
	firstNameOK.x = display.contentWidth - 30
	firstNameOK.y = firstNameField.y - 6
	firstNameOK.alpha = 0
	view:insert(firstNameOK)

	-------------------------
	
 	lastNameField = native.newTextField( 
   	display.contentWidth * 0.125, 
   	display.contentHeight/2 + 80, 
   	display.contentWidth * 0.7
   	, 30 
	)
	lastNameField:setTextColor( 0 )	
	lastNameField.align = "center"
	lastNameField.size = 14
	lastNameField.text = LASTNAME_DEFAULT_TEXT
	lastNameField:setReferencePoint( display.CenterReferencePoint )
	lastNameField:addEventListener( "userInput", lastNameHandler )
	view:insert( lastNameField )
	
	lastNameOK = display.newImage( "images/icons/ok.png", false )
	lastNameOK.x = display.contentWidth - 30
	lastNameOK.y = lastNameField.y - 6
	lastNameOK.alpha = 0
	view:insert(lastNameOK)

	-------------------------
	
	headlineField = native.newTextField( 
   	display.contentWidth * 0.125, 
   	display.contentHeight/2 + 120, 
   	display.contentWidth * 0.7
   	, 30 
	)
	headlineField:setTextColor( 0 )	
	headlineField.align = "center"
	headlineField.size = 14
	headlineField.text = HEADER_DEFAULT_TEXT
	headlineField:setReferencePoint( display.CenterReferencePoint )
	headlineField:addEventListener( "userInput", headlineHandler )
	view:insert( headlineField )
	
	headlineOK = display.newImage( "images/icons/ok.png", false )
	headlineOK.x = display.contentWidth - 30
	headlineOK.y = headlineField.y - 6
	headlineOK.alpha = 0
	view:insert(headlineOK)

	-------------------------
	
	validateButton = widget.newButton	{
		width 	= 50,
		height 	= 40,
		label 	= "OK", 
		labelYOffset = -2,
		onRelease = validate
	}
	
   validateButton.x = display.contentWidth/2
   validateButton.y =  5*display.contentHeight/6
	
	validateButton.alpha = 0
	view:insert( validateButton )
end

---------------------------------------------------

function emailHandler( event )
	textFieldHandler(event, emailField, emailOK, EMAIL_DEFAULT_TEXT, "email")
end

function firstNameHandler( event )
	textFieldHandler(event, firstNameField, firstNameOK, FIRSTNAME_DEFAULT_TEXT, "firstName")
end

function lastNameHandler( event )
	textFieldHandler(event, lastNameField, lastNameOK, LASTNAME_DEFAULT_TEXT, "lastName")
end

function headlineHandler( event )
	textFieldHandler(event, headlineField, headlineOK, HEADER_DEFAULT_TEXT, "headline")
end

---------------------------------------------------

function textFieldHandler( event, field, ok, defaultText, data )

	if ( "began" == event.phase) then

		if (field.text == defaultText ) then
   		field.text = ""
      	transition.to( ok, { alpha = 0 } )
   	end

	elseif ( "editing" == event.phase ) then
   	ok.alpha = 0
		validateButton.alpha = 0
		
	elseif ( "ended" == event.phase ) then

		if(field.text == "") then
   		transition.to( ok, { alpha = 0, time = 100, onComplete = checkValidation } )
			field.text = defaultText
		elseif(data == "email" and not utils.isEmail(field.text)) then
   		transition.to( ok, { alpha = 0, time = 100, onComplete = checkValidation } )
		else
			localData.user[data] = tostring( field.text )
   		transition.to( ok, { alpha = 1, time = 100, onComplete = checkValidation } )
		end 

	end 
end 

function checkValidation()
	if(firstNameOK.alpha > 0 and lastNameOK.alpha > 0 and headlineOK.alpha > 0 and emailOK.alpha > 0) then
		validateButton.alpha = 1
	else
		validateButton.alpha = 0
	end
end

function validate()
	emailField:removeSelf()
	firstNameField:removeSelf()
	lastNameField:removeSelf()
	headlineField:removeSelf()

	analytics.event("Navigation", "appHomeValidate")
	accountManager.newUser()
end


-------------------------------------------------------------------------------------------------------------
-- SCENE
-------------------------------------------------------------------------------------------------------------

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
--	loadingSpinner.alpha = 0
--	cancelButton.alpha = 0
--	transition.to( signInButton, { alpha = 1 } )
--	enterSceneBeforeTimerComplete = true
	viewManager.removeHeader()
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