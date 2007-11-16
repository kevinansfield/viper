module Dependencies #:nodoc:
  extend self

  # tracks object that when modified should reload other objects (like reverse dependencies)
  #
  # { "FakeHelper"=>["AccountsHelper"], "ActiveRecord::Base"=>["Account", "User", "Role", "Membership"],
  # "ApplicationController"=>["AccountsController"], "Account" => ["BigAccount"] }
  #
  # if FakeHelper is modified then AccountsHelper (which includes it) will be flushed as well
  # if ApplicationController is modified then AccountsController (which is a subclass) will be flushed as well
  #
  # it also works recursively, if AR:Base is modified (lets just say) that will result in Account, User, Role,
  # and Membership being flushed, but also BigAccount because it depends on Account
  mattr_accessor :reload_objects_tree
  self.reload_objects_tree = {}

  # tracks which file define which objects so if a file is changed we known which object need to be flushed
  #
  # TODO - update this help
  # remove_constants_by_file uses this hash to determine if objects should be flushed when the source file changes
  #
  # also tracks which classes depend on changes to a given file so you might see this:
  mattr_accessor :file_associations
  self.file_associations = {}

  mattr_accessor :object_defined_by
  self.object_defined_by = {}
  
  # stores the last time a file was changed 
  # used to check to see if a given file needs to be reloaded before a request
  mattr_accessor :file_modifications
  self.file_modifications = {}

  # get all constants associated with a file, :defines and :related
  def associated_constants_for_file(filename)
    return [] if not file_associations[filename] or file_associations[filename].empty?
    file_associations[filename].map { |x| x[1] }.flatten
  end

  def track_file_association(filename, connection, constants)
    file_associations[filename] ||= {}
    
    constants=[constants] unless constants.is_a? Array
    # we really don't ever want to flush the dispatcher
    constants.delete_if { |c| c.to_s=="Dispatcher" }
    if connection==:defines
      constants.map(&:to_s).each do |con|
        object_defined_by[con]=filename
      end
    end
    unless constants.empty?
      file_associations[filename][connection] ||= []
      file_associations[filename][connection].concat constants.map(&:to_s)
    end
  end

  def depend_on(file_name, swallow_load_errors = false, parent=nil)
    path = search_for_file(file_name)
    require_or_load(path || file_name)
    # if this path changes, then we need to reload the parent since
    # the parent is including it (this should handle helpers)
    track_file_association(path, :related, parent) unless parent.nil?
  rescue LoadError
    raise unless swallow_load_errors
  end


  def load_file(path, const_paths = loadable_constants_for_path(path))
    log_call path, const_paths
    const_paths = [const_paths].compact unless const_paths.is_a? Array
    parent_paths = const_paths.collect { |const_path| /(.*)::[^:]+\Z/ =~ const_path ? $1 : :Object }
    
    result = nil
    newly_defined_paths = new_constants_in(*parent_paths) do
      result = load_without_new_constant_marking path
    end
    # incase a module was added to autoloaded_constants in the above load, we need to remove it
    # so it is not unloaded at the beginning of the next request, but rather left up to the
    # file references to decide when it needs to be unloaded based on file mtimes
    autoloaded_constants.delete_if { |ac| newly_defined_paths.include? ac }
    
    log "loading #{path} defined #{newly_defined_paths * ', '}" unless newly_defined_paths.empty?
    # keep track of which objects this file defines
    track_file_association(path, :defines, newly_defined_paths)
    # and the last time it was modified
    file_modifications[path]= File.stat(path).mtime
    return result
  end


  def clear
    log "overridden clear"
    log_call
    log "RELOAD OBJECTS TREE: #{reload_objects_tree.inspect}"
    log "FILE ASSOCIATIONS: #{file_associations.inspect}"
#    log "OBJECT DEFINED BY: #{object_defined_by.inspect}"
    unload_constants_by_file_modifications
    loaded.clear
    remove_unloadable_constants!
  end

  def unload_constants_by_file_modifications
    log_call
    
    file_modifications.dup.each do |file, value|
      # return nil if we can't find the file (deleted)
      mtime=File.stat(file).mtime rescue nil
      # if the file has changed
      if mtime.nil? or mtime>value
        # remove the constants and forget that we ever loaded this file
        constants=associated_constants_for_file(file)
        log "  UNLOADING #{"(deleted)" if mtime.nil?} #{file}: #{constants.join ","}"
        remove_constants_by_file(file,constants)
        # update mtime or remove the file from the modifications hash
        mtime ? file_modifications[file]=mtime : file_modifications.delete(file)
      end
    end
  end

  def smart_remove_constant(const)
    log_call const
    if reload_objects_tree.include?(const.to_s)
      reload_objects_tree[const.to_s].each { |c| smart_remove_constant c }
      reload_objects_tree[const.to_s]=[]
    end
    # if we know the file that defines this constant, then flush it's associated constants as well
    if object_defined_by[const.to_s]
      remove_constants_by_file(object_defined_by[const.to_s])
    end
    remove_constant const
  end
  
  def remove_constants_by_file(filename,constants=nil)
    log_call filename
    constants=associated_constants_for_file(filename) if constants.nil?
    constants.each do |const|
      # we can skip going thru the object space for non AR objects
      next unless const.constantize.ancestors.map(&:to_s).include?("ActiveRecord::Base") rescue next
      # this is to break any references that assocations have to the old glass
      ObjectSpace.each_object(ActiveRecord::Reflection::MacroReflection) do |ass| 
        if ass.class_name==const.to_s
          log " ** #{ass.active_record} #{ass.macro} #{const} - resetting"
          # set @klass to nil, it'll be reset from the master class the next time it's accessed
          ass.instance_variable_set "@klass", nil 
          ass.instance_variable_set "@class_name", nil 
          if ass.is_a? ActiveRecord::Reflection::AssociationReflection
            ass.instance_variable_set "@table_name", nil 
            ass.instance_variable_set "@through_reflection", nil 
            ass.instance_variable_set "@source_reflection", nil 
            ass.instance_variable_set "@primary_key_name", nil 
            ass.instance_variable_set "@association_foreign_key", nil 
          end
        end
      end 
    end
    # remove any refernces to this file, it should be auto-loaded again soon
    file_associations.delete filename
    constants.each { |const| smart_remove_constant const }
  end

end

Object.send(:define_method, :require_dependency)  { |file_name| Dependencies.depend_on(file_name, false, self) }       unless Object.respond_to?(:require_dependency)

class Module
  
  alias :original_included :included
  
  def included(to_module)
    # if this module is modified then we need to reload the higher level module
    # theck for # signs so we only log named modules
    unless self.to_s[0..0]=="#" or to_module.to_s[0..0]=="#"
      Dependencies.reload_objects_tree[self.to_s]||=[]
      Dependencies.reload_objects_tree[self.to_s]<< to_module.to_s
    end
    original_included(to_module)
  end
  
end

class Class

    # alias :old_inherited :inherited
    
    # this is slick, but it goes us WAY too many objects to track
    # def inherited(subclass)
    #   puts "CLASS INHERITED: #{subclass} inherits #{self}"
    #   Dependencies.reload_objects_tree[self.to_s]||=[]
    #   Dependencies.reload_objects_tree[self.to_s] << subclass.to_s
    #   old_inherited(subclass)
    # end
  
  def const_missing(class_id)
#   puts "CONST MISSING: #{self.inspect} needs: #{class_id}"
    if [Object, Kernel].include?(self) || parent == self
#     puts " -> calling super"
      x=super
      if x.is_a? Class
        Dependencies.reload_objects_tree[x.superclass.to_s]||=[]
        Dependencies.reload_objects_tree[x.superclass.to_s] << x.to_s
#       puts Dependencies.reload_objects_tree.inspect
      end
      x
    else
      begin
        begin
#         puts " -> loading missing constant #{self.inspect} #{class_id}"
          Dependencies.load_missing_constant self, class_id
        rescue NameError
#         puts " -> parent.send :const_missing"
          parent.send :const_missing, class_id
        end
      rescue NameError => e
        # Make sure that the name we are missing is the one that caused the error
        parent_qualified_name = Dependencies.qualified_name_for parent, class_id
        raise unless e.missing_name? parent_qualified_name
        qualified_name = Dependencies.qualified_name_for self, class_id
        raise NameError.new("uninitialized constant #{qualified_name}").copy_blame!(e)
      end
    end
  end
end