ActionController::Routing::Routes.draw do |map|
  # map.resources :notes
  # map.resources :blogs
  
  map.root :controller => "intro"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
