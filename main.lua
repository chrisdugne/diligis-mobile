-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local json = require "json"
local xml = require "libs.Xml"
local utils = require "libs.Utils"
local linkedIn = require "libs.social.LinkedIn"

local imageLoader = require "libs.ImageLoader"

-----------------------------------------------------------------------------------------
print("Youhou !");

-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget = require "widget"
local storyboard = require "storyboard"


-- event listeners for tab buttons:
local function onFirstView( event )
	storyboard.gotoScene( "views.view1" )
end

local function onSecondView( event )
	storyboard.gotoScene( "views.view2" )
end

------------------------------------------

local function linkedInConnect( event )
	linkedIn.init();
	linkedIn.authorise(linkedInConnected);
end

function linkedInConnected()
	print ( "linkedInConnected : " .. linkedIn.data.profile.pictureUrl )
	imageLoader.loadImage(linkedIn.data.profile.pictureUrl, "profile.png", 30, 30);
end

------------------------------------------

-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="First", up="images/icon1.png", down="images/icon1-down.png", width = 32, height = 32, onPress=onFirstView, selected=true },
	{ label="Second", up="images/icon2.png", down="images/icon2-down.png", width = 32, height = 32, onPress=onSecondView },
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
--	top = 0;
	buttons = tabButtons
}

-----------------------------------------------------------------------------------------

--local response = xml.parseXML("<Response><timestamp>1359986829</timestamp><num_bytes>1942</num_bytes><Trip><TripInvitees><Invitee profile_ref=\"vwM3BONpzCa19Cq_oQI3KA\"><is_read_only>false</is_read_only><is_traveler>true</is_traveler><is_owner>true</is_owner></Invitee></TripInvitees><id>62611004</id><relative_url>/trip/show/id/62611004</relative_url><start_date>2013-02-28</start_date><end_date>2013-03-04</end_date><display_name>London, United Kingdom, February 2013</display_name><image_url>https://www.tripit.com/images/places/london.jpg</image_url><is_private>false</is_private><primary_location>London, United Kingdom</primary_location><PrimaryLocationAddress><address>London, United Kingdom</address><city>London</city><state>England</state><zip>SE11</zip><country>GB</country><latitude>51.5</latitude><longitude>-0.116667</longitude></PrimaryLocationAddress><TripPurposes><purpose_type_code>B</purpose_type_code><is_auto_generated>false</is_auto_generated></TripPurposes><last_modified>1359977072</last_modified></Trip><Profile ref=\"vwM3BONpzCa19Cq_oQI3KA\"><ProfileEmailAddresses><ProfileEmailAddress><address>chris@dwaggle.com</address><is_auto_import>true</is_auto_import><is_confirmed>true</is_confirmed><is_primary>true</is_primary><is_auto_inbox_eligible>true</is_auto_inbox_eligible></ProfileEmailAddress></ProfileEmailAddresses><is_client>true</is_client><is_pro>false</is_pro><screen_name>chris48111</screen_name><public_display_name>Chris Dugne</public_display_name><profile_url>people/chris48111</profile_url><home_city>Paris, France</home_city><activity_feed_url>https://www.tripit.com/feed/activities/private/E0C74AE9-761EDA2B4730388D284E0BFEF0DC31D9/activities.atom</activity_feed_url><alerts_feed_url>https://www.tripit.com/feed/alerts/private/E0C74AE9-A3A45FD677E862C09112AB4145E9ED3B/alerts.atom</alerts_feed_url><ical_url>webcal://www.tripit.com/feed/ical/private/E0C74AE9-2384FD8B55BF36EDAEBDC7AB153E8F99/tripit.ics</ical_url></Profile></Response>").Response
local response = xml.parseXML("<Response><timestamp>1359989284</timestamp><num_bytes>2859</num_bytes><Trip><TripInvitees><Invitee profile_ref=\"vwM3BONpzCa19Cq_oQI3KA\"><is_read_only>false</is_read_only><is_traveler>true</is_traveler><is_owner>true</is_owner></Invitee></TripInvitees><id>62626295</id><relative_url>/trip/show/id/62626295</relative_url><start_date>20130220</start_date><end_date>20130221</end_date><display_name>Tolosa !</display_name><image_url>https://www.tripit.com/images/places/defaulttraveler.png</image_url><is_private>false</is_private><primary_location>Toulouse, France</primary_location><PrimaryLocationAddress><address>Toulouse, France</address><city>Toulouse</city><state>Midipyrénées</state><zip>31001 CEDEX 6</zip><country>FR</country><latitude>43.604262</latitude><longitude>1.443672</longitude></PrimaryLocationAddress><TripPurposes><purpose_type_code>B</purpose_type_code><is_auto_generated>false</is_auto_generated></TripPurposes><last_modified>1359988731</last_modified></Trip><Trip><TripInvitees><Invitee profile_ref=\"vwM3BONpzCa19Cq_oQI3KA\"><is_read_only>false</is_read_only><is_traveler>true</is_traveler><is_owner>true</is_owner></Invitee></TripInvitees><id>62611004</id><relative_url>/trip/show/id/62611004</relative_url><start_date>20130228</start_date><end_date>20130304</end_date><display_name>London, United Kingdom, February 2013</display_name><image_url>https://www.tripit.com/images/places/london.jpg</image_url><is_private>false</is_private><primary_location>London, United Kingdom</primary_location><PrimaryLocationAddress><address>London, United Kingdom</address><city>London</city><state>England</state><zip>SE11</zip><country>GB</country><latitude>51.5</latitude><longitude>0.116667</longitude></PrimaryLocationAddress><TripPurposes><purpose_type_code>B</purpose_type_code><is_auto_generated>false</is_auto_generated></TripPurposes><last_modified>1359977072</last_modified></Trip><Profile ref=\"vwM3BONpzCa19Cq_oQI3KA\"><ProfileEmailAddresses><ProfileEmailAddress><address>chris@dwaggle.com</address><is_auto_import>true</is_auto_import><is_confirmed>true</is_confirmed><is_primary>true</is_primary><is_auto_inbox_eligible>true</is_auto_inbox_eligible></ProfileEmailAddress></ProfileEmailAddresses><is_client>true</is_client><is_pro>false</is_pro><screen_name>chris48111</screen_name><public_display_name>Chris Dugne</public_display_name><profile_url>people/chris48111</profile_url><home_city>Paris, France</home_city><activity_feed_url>https://www.tripit.com/feed/activities/private/E0C74AE9761EDA2B4730388D284E0BFEF0DC31D9/activities.atom</activity_feed_url><alerts_feed_url>https://www.tripit.com/feed/alerts/private/E0C74AE9A3A45FD677E862C09112AB4145E9ED3B/alerts.atom</alerts_feed_url><ical_url>webcal://www.tripit.com/feed/ical/private/E0C74AE92384FD8B55BF36EDAEBDC7AB153E8F99/tripit.ics</ical_url></Profile></Response>").Response
print(response.timestamp.value)
print(response.num_bytes.value)
print(response.Trip[2].id.value)

for i in pairs(response.Trip) do
	print("trip : " .. response.Trip[i].display_name.value)
end

-- search for substatement having the tag "scene" 

-----------------------------------------------------------------------------------------

onFirstView()	-- invoke first tab button's onPress event manually

-----------------------------------------------------------------------------------------

--local function networkListener( event )
--	if ( event.isError ) then
--		print( "Network error!")
--	else
--		local data = json.decode( event.response )
--		local styles = data.styles; 
--		
--		-- Go through the array in a loop
--		for i in pairs(styles) do
--			local style = styles[i] 
--			print(style.name)
--			
--			-- create some text
--			local styleName = display.newRetinaText( style.name, 0, 0, native.systemFont, 32 )
--			styleName:setTextColor( 255 )	
--			styleName:setReferencePoint( display.CenterReferencePoint )
--			styleName.x = display.contentWidth * 0.5
--			styleName.y = 225 + i*50;
--		end
--	end
--end

--local json_file_by_get = jsonFile( network.request( "http://mapnify.herokuapp.com/getPublicData", "POST", networkListener ) )
--local json_file_by_get = jsonFile( network.request( "http://localhost:9000/getPublicData", "POST", networkListener ) )

-----------------------------------------------------------------------------------------


