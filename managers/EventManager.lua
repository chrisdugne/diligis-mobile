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
	native.setActivityIndicator( false )
	router.displayStream();
end

-----------------------------------------------------------------------------------------

function sendAnswer(text, contentUID, journeyId)
	native.setActivityIndicator( true )
	utils.postWithJSON({
		message = {
			text 			= text,
			contentUID 	= contentUID,
			journeyId 	= journeyId
		}
	},
	SERVER_URL .. "/sendAnswer")
end

function sendMessage(text, senderEmail, journeyId)
	native.setActivityIndicator( true )
	utils.postWithJSON({
		message = {
			text 				= text,
			senderEmail 	= senderEmail,
			journeyId 		= journeyId
		}
	},
	SERVER_URL .. "/sendMessage")
end