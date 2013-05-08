-----------------------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------------------

stream = {}

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
	router.openHome();
end

-----------------------------------------------------------------------------------------