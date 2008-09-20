ActionController::Routing::Routes.draw do |map|
  # map.resources :notes
  # map.resources :blogs

  map.root :controller => "intro"

  # See how all your routes lay out with "rake routes"

  TinyMceGzip::Routes.add_routes

#  map.resources :notes do |note|
#    note.resources :comments
#  end

  # Install the default routes as the lowest priority.
#  map.connect ':controller/:id', :action => "show"
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
