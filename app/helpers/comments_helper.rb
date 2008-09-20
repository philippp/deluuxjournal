module CommentsHelper
  def author_link_for_comment(comment)
    if comment.author_url and comment.author_url[0...7] == "http://"
      link_to(h(comment.author_name), comment.author_url) 
    else 
      h(comment.author_name) 
    end 
  end

end
