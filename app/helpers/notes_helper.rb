module NotesHelper

  def tiny_mce_js_include
    "<script type=\"text/javascript\" src=\"http://#{request.host_with_port}/javascripts/tiny_mce/tiny_mce.js\"></script>"
  end

  def deluuxjournal_js_include
    "<script type=\"text/javascript\" src=\"http://#{request.host_with_port}/javascripts/detect_friends.js\"></script><script type=\"text/javascript\" src=\"http://#{request.host_with_port}/javascripts/load_grid.js\"></script>"
  end

  def render_asset_grid(row_count, col_count)
    grid_str = "<table class='asset_grid'>\n"
    (0...row_count).each{ |row_id|
      grid_str += "\t<tr>"
      (0...col_count).each{ |col_id|
        grid_str += "<td id='ag_#{row_id}_#{col_id}' class='asset_cell' style='padding:1em;'></td>"
      }
      grid_str += "<tr>\n"
    }
    grid_str += "</table>"
    return grid_str
  end


  def render_asset_friend_js(assets, friends)

   # myFriendList = [ [friend_id, "friend_name", [friend_regex_fullname, friend_regex_partialname, ...]], ...] -->
    rb_array_friends = []; rb_list_friends_decl = ""

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

    js_array_friends = rb_array_friends.join(",");
    return "<script type=\"text/javascript\">
  #{ rb_list_friends_decl }

  var myFriendList = new Array( #{ js_array_friends } );

  var get_friend_by_id = function(friend_id){
    for( var i = 0; i < myFriendList.length; i++ ){
       if( myFriendList[i][0] == friend_id ){ return myFriendList[i]; };
    }
  }
</script>"
  end

end
