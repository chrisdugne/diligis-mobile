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
	utils.postWithJSON({
		user = accountManager.user;
	},
	SERVER_URL .. "/getStream", 
	getStreamListener)
end

function getStreamListener( event )
	stream = json.decode(event.response);
	router.openStream();
end

-----------------------------------------------------------------------------------------