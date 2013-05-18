-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

stream = {}

-----------------------------------------------------------------------------------------

ANNOUNCEMENT	= 0;
DILIGIS 			= 1;
MESSAGE 			= 2;
INVITATION 		= 3;
MEETING 			= 4;

-----------------------------------------------------------------------------------------
--

function getStream()
	native.setActivityIndicator( true )
	utils.postWithJSON({
		user = accountManager.user;
	},
	SERVER_URL .. "/getStream", 
	getStreamListener)
end

function getStreamListener( event )
	stream = json.decode(event.response);
	utils.tprint(stream)
	native.setActivityIndicator( false )
	router.openStream();
end

-----------------------------------------------------------------------------------------

function sendMessage(text, contentUID, tripFromId)
	native.setActivityIndicator( true )
	utils.postWithJSON({
		message = {
			text 			= text,
			contentUID 	= contentUID,
			tripFromId 	= tripFromId
		}
	},
	SERVER_URL .. "/sendMessage", 
	messageSent)
end

function messageSent( event )
	answer = event.response;
	print(answer)
	native.setActivityIndicator( false )
	router.openTrips();
end