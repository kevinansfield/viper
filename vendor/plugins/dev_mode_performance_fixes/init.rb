# these hacks are only for faster development
if RAILS_ENV=="development"
# we need to load the rails dispatcher because normally it's not loaded so early
  require 'dispatcher'
  require 'dispatcher_hacks'
  Dispatcher.send :include, DispatcherHacks

  require 'dependencies'
  # this patch has already made it into Rails edge for 2.0
  require 'routing_patches'
end

