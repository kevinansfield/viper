module DispatcherHacks
  
    def self.included(base)
      class << base
        
        def prepare_application_with_app_reset
          reset_application! if Dependencies.load?
          prepare_application_without_app_reset
        end
        alias_method_chain :prepare_application, :app_reset

        def reset_after_dispatch
          # we no longer want to reset AFTER the dispatch, but rather before it
          # reset_application! if Dependencies.load?
          Breakpoint.deactivate_drb if defined?(BREAKPOINT_SERVER_PORT)
        end
        
        def reset_application!
          ActiveRecord::Base.reset_subclasses if defined?(ActiveRecord)
          
          Dependencies.clear
          
          # this is depreciated - if we're a smart enough developer to be using
          # this plugin then we shouldn't still be using reloadable in our code
          # so we can safely just go ahead and comment this out
          
          # ActiveSupport::Deprecation.silence do # TODO: Remove after 1.2
          #   Class.remove_class(*Reloadable.reloadable_classes)
          # end
          
          # this appears superfulous but was added via: http://dev.rubyonrails.org/changeset/5637
          #
          # evidentally sqlite3 needs the connection reset between requests (to 
          # detect schema changes only?) so one would expect this lines impact on 
          # other databases to be minimal... however with sqlite3 there is a real
          # difference of 10req/s (from 40 down to 30) in my tests
          ActiveRecord::Base.clear_reloadable_connections! if defined?(ActiveRecord)
        end
        
      end
    end
   
end