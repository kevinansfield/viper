ActionController::Routing::Routes.draw do |map|
  
  # Named routes
  map.activate  'user/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.signup    'user/signup',    :controller => 'users',    :action => 'new'
  map.register  'user/register',  :controller => 'users',    :action => 'create'
  map.login     'user/login',     :controller => 'sessions', :action => 'new'
  map.new_login 'user/login',     :controller => 'sessions', :action => 'new'
  map.hub       'user/hub',       :controller => 'users',    :action => 'hub'
  map.logout    'user/logout',    :controller => 'sessions', :action => 'destroy'
  map.activate_new_email  'user/activate_new_email/:email_activation_code', :controller => 'users', :action => 'activate_new_email'
  map.forgot_password     'user/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password      'user/reset_password/:id', :controller => 'users', :action => 'reset_password'

  # User resources
  map.resources :users, :member => { :change_email => :put,
                                     :change_password => :put,
                                     :invite => :get,
                                     :send_invite => :put,
                                     :articles => :get,
                                     :suspend => :put,
                                     :unsuspend => :put,
                                     :purge => :delete },
                        :has_many => [:forum_posts] do |user|
    user.resource :profile
    user.resource :avatar, :member => { :crop => :put }
    user.resource :bio
    user.resources :messages, :collection => { :sent => :get }, :member => { :reply => :get }
    user.resource :wall do |wall|
      wall.resources :comments
    end
  end
  map.resource  :sessions
  
  # Blog resources
  map.resources :blogs do |blog|
    blog.resources :posts do |post|
      post.resources :comments
    end
  end
  
  # News resources
  map.resources :news, :singular => :news_item
  
  # Article resources
  map.resources :categories do |category|
    category.resources :articles
  end
  
  # Comment resources
  map.resources :comments, :collection => {:destroy_multiple => :delete},
                :member => {:approve => :put, :reject => :put}
                
  # Forum resources
  map.resources :moderatorships
  map.resources :forums, :has_many => :posts do |forum|
    forum.resources :topics, :controller => 'forum_topics' do |topic|
      topic.resources :posts, :controller => 'forum_posts'
    end
    forum.resources :posts, :controller => 'forum_posts'
  end
  map.resources :forum_posts, :collection => {:search => :get}
  
  # Search routes
  map.search 'community/search', :controller => 'community', :action => 'search'

  map.root :controller => 'site', :action => 'index'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
