module NotesHelper

  def tiny_mce_js_include
    "<script type=\"text/javascript\" src=\"http://#{request.host_with_port}/javascripts/tiny_mce/tiny_mce.js\"></script>"
  end

  def render_asset_friend_js(assets, friends)
   # Generate JS Arrays of Image Assets and Friends -->
   # myImageList = [ [title, filename], ...] -->
   # myFriendList = [ [friend_id, "friend_name", [friend_regex_fullname, friend_regex_partialname, ...]], ...] -->
    rb_array_assets = []; rb_array_friends = []; rb_list_friends_decl = ""

    assets.each do |asset|
      if asset["title"] and asset["title"].length > 0
        rb_array_assets << "[\"#{asset["title"]}\", \"#{asset["public_filename"]}\"]"
      else
        rb_array_assets << "[\"#{asset["public_filename"].split("/").last}\", \"#{asset["public_filename"]}\"]"
      end
    end
    # <!-- Friend array -->
    ignore_words = ["the", "new", "mail", "admin", "root", "founders", "help"]

    friends.each do |friend|
      friend_name_array = ["new RegExp(\"\s#{friend["name"]}\s\", \"i\")"]
      friend["name"].split(" ").each{|fn|
        friend_name_array << "new RegExp(\"\s#{fn}\s\", \"i\")" unless ( fn.length < 3 or ignore_words.include? fn.downcase )
      }
      rb_list_friends_decl << "var friend_#{friend["id"]} = new Array(#{friend["id"]}, \"#{friend["name"]}\", new Array(#{friend_name_array.join(",")}));\n"
      rb_array_friends << "friend_#{friend["id"]}"
    end

    js_array_assets = rb_array_assets.join(","); js_array_friends = rb_array_friends.join(",");
    return "<script type=\"text/javascript\">
  #{ rb_list_friends_decl }
  var myImageList = new Array( #{ js_array_assets } );
  var myFriendList = new Array( #{ js_array_friends } );

  var get_friend_by_id = function(friend_id){
    for( var i = 0; i < myFriendList.length; i++ ){
       if( myFriendList[i][0] == friend_id ){ return myFriendList[i]; };
    }
  }
</script>"
  end

end
