-----------------------------------------------------------------------------------------

module(..., package.seeall)

local OAuth = require "libs.oauth.oAuth"

-- Fill in the following fields from your Twitter app account
consumer_key = "643408271777.apps.googleusercontent.com"			-- key string goes here
consumer_secret = "IvBmA3QvF0k2kAR20Slh7S03"	-- secret string goes here

-- The web URL address below can be anything
-- Twitter sends the webaddress with the token back to your app and the code strips out the token to use to authorise it
--
webURL = "http://localhost:9000/"

-- Note: Once logged on, the access_token and access_token_secret should be saved so they can
--	     be used for the next session without the user having to log in again.
-- The following is returned after a successful authenications and log-in by the user
--

-----------------------------------------------------------------------------------------

function test()
	print("google.test")
	local client = OAuth.new("anonymous", "anonymous", {
		RequestToken = "https://www.google.com/accounts/OAuthGetRequestToken",
		AuthorizeUser = {"https://www.google.com/accounts/OAuthAuthorizeToken", method = "GET"},
		AccessToken = "https://www.google.com/accounts/OAuthGetAccessToken"
	})

	local request_token = client:RequestToken({ oauth_callback = "oob", scope = "https://www.google.com/analytics/feeds/" })

	assert( not string.match(request_token.oauth_token, "%%") )
	print(request_token.oauth_token)

	local auth_url = client:BuildAuthorizationUrl()
	print("Test authorization at the following URL")
	print(auth_url)
	print(string.match(auth_url, "oauth_token=([^&]+)&"))
end
