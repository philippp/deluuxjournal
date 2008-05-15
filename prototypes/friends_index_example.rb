require 'ruby-debug'
require 'fb/facebook_web_session'
Debugger.start
@api_key = "Qnmqv3ATOBbXE6hI0LIWCZWz6BD7YvXO"
@api_secret = "QiYnRMVBCzrinKr0nR5mYPu0AiSG0MXT"
@fb = RFacebook::FacebookWebSession.new(@api_key, @api_secret)
@fb.session_key = "UrZljHwV7UZO1Hw3k7fsIMLE"
fi = @fb.friends_index

assets = []
fi.root.children.each{ |asset|
  # HACK:
  # Colony is returning terminated space-only strings 
  # between asset nodes
  # TODO: filter xml output
  next unless asset.class == Hpricot::Elem and asset.name == "asset"
  asset_hash = {}
  asset.children.each{ |attribute|
    next unless attribute.class == Hpricot::Elem
    asset_hash[attribute.name] = attribute.innerText
  }
  assets << asset_hash
}
pp assets
