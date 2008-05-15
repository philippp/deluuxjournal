require 'fb/facebook_web_session'
@api_key = "Qnmqv3ATOBbXE6hI0LIWCZWz6BD7YvXO"
@api_secret = "QiYnRMVBCzrinKr0nR5mYPu0AiSG0MXT"
@fb = RFacebook::FacebookWebSession.new(@api_key, @api_secret)
@fb.session_key = "UrZljHwV7UZO1Hw3k7fsIMLE"
@fb.friends_index

