module NotesHelper

  def tiny_mce_js_include
    "<script type=\"text/javascript\" src=\"http://#{request.host_with_port}/javascripts/tiny_mce/tiny_mce.js\"></script>"
  end

end
