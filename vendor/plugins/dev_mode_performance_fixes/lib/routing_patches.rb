ActionController::Routing::RouteSet.class_eval do

  def load_routes!
    if defined?(RAILS_ROOT) && defined?(::ActionController::Routing::Routes) && self == ::ActionController::Routing::Routes
      load File.join("#{RAILS_ROOT}/config/routes.rb")
      @routes_last_modified=File.stat("#{RAILS_ROOT}/config/routes.rb").mtime
    else
      add_route ":controller/:action/:id"
    end
  end   

  def reload
    if @routes_last_modified
      mtime=File.stat("#{RAILS_ROOT}/config/routes.rb").mtime
      # if it hasn't been changed, then just return
      return if mtime == @routes_last_modified
      # if it has changed then record the new time and fall to the load! below
      @routes_last_modified=mtime
    end
    load!
  end

end