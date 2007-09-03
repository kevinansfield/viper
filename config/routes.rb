ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "site"

  # User resources
  map.resources :users, :members => { :change_email => :change_email }
  map.resource  :session
  
  # User named routes
  map.activate  'user/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.signup    '/signup',    :controller => 'users',   :action => 'new'
  map.hub       '/user/hub',  :controller => 'users',   :action => 'hub'
  map.login     '/login',     :controller => 'session', :action => 'new'
  map.logout    '/logout',    :controller => 'session', :action => 'destroy'
  map.activate_new_email  'user/activate_new_email/:email_activation_code', :controller => 'users', :action => 'activate_new_email'
  map.forgot_password     'user/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password      'user/reset_password/:id', :controller => 'users', :action => 'reset_password'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
