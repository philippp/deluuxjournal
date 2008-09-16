var included_friends = []; // Structure ["matched_text", [friend_1, friend_2, ...]]
var friend_notify_list = [];

/**
 * Checks a body of text (to_check) for friends that have been mentioned in it.
 * Calls add_friend and update_friend_list
 * @param to_check content in which friends may be mentioned
 * @param list_target_id Element ID, select elements are rendered into here
 */
var check_friends = function(to_check, list_target_id){
    included_friends = [];
    for(var i = 0; i < myFriendList.length; i++ ){ //Each friend
       friend = myFriendList[i];
       for(var j = 0; j < friend[2].length; j++ ){ // Each RegEx for this friend
         var text_match = to_check.match(friend[2][j])
         if( text_match ){
           add_friend( friend, text_match[0] );
           break; // Skip friend's remaining RegExs
         }
       }
    }
   update_friend_list( list_target_id );
  }

/**
 * Adds the Friend to the list of friends included in the post. We also track the matched
 * text to group Friends that have been matched ambiguously.
 */
var add_friend = function(friend, matched_string ){
    for(var i=0; i < included_friends.length; i++ ){
       if( included_friends[i][0] == matched_string ){
          included_friends[i][1].push(friend);
          return included_friends;
       }
    }
    friend_match = new Array(matched_string, [friend]);
    included_friends.push( friend_match );
    return included_friends;
}

var update_friend_list = function(target_id){

  if( included_friends.length > 0 ){
    $(target_id).innerHTML = "<h4><b>Did you mention...</b></h4><ul>";
    for( var i = 0; i < included_friends.length; i++){
      if( included_friends[i][1].length > 1 ){
        $(target_id).innerHTML += "<li>"+included_friends[i][0]+"<ul>";
        for( var j = 0; j < included_friends[i][1].length; j++){
          $(target_id).innerHTML += "<li class='second_level'><a href='#' onclick='add_friend_notify("+included_friends[i][1][j][0]+");'>"+included_friends[i][1][j][1]+"</a></li>";
        }
        $(target_id).innerHTML += "</ul></li>";
      }else{
        $(target_id).innerHTML += "<li><a href='#' onclick='add_friend_notify("+included_friends[i][1][0][0]+");'>"+included_friends[i][1][0][1]+"</a></li>";
      }
    }//for( var i = 0; i < included_friends.length; i++)
    $(target_id).innerHTML += "</ul><i>Click and tell!</i>";
  }else{
    $(target_id).innerHTML = "";
  }
}

var add_friend_notify = function(friend_id){
  friend = get_friend_by_id( friend_id );
  friend_notify_list.push( friend );
  update_friend_notify_field();
}

var remove_friend_notify = function( friend_id ){
  for( var i = 0; i < friend_notify_list.length; i++ ){
    if( friend_notify_list[i][0] == friend_id ){ friend_notify_list.splice(i,1); };
  }
  update_friend_notify_field();
}

var update_friend_notify_field = function(){
  $("friend_notify_target").innerHTML = "";
  $("notify_id_list").value = "";
  for( var i = 0; i < friend_notify_list.length; i++ ){
    var friend = friend_notify_list[i];
    $("notify_id_list").value += friend[0]+",";
    $("friend_notify_target").innerHTML += "<p>"+friend[1]+"&nbsp;<a href='#' onclick='remove_friend_notify("+friend[0]+");'>[X]</a></p>";
  }
}


setInterval("check_friends(tinyMCE.getInstanceById('text').getDoc().body.innerHTML, 'friend_target');", 5000);
