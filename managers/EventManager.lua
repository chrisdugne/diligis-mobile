-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

stream = {}

-----------------------------------------------------------------------------------------
--

function getStream()
	router.callServer({
		user = accountManager.user;
	},
	"getStream", 
	getStreamListener)
end

function getStreamListener( event )
	stream = json.decode(event.response);
	router.openHome();
end

-----------------------------------------------------------------------------------------