#Reopen Dir class to add #empty? method
unless Dir.method_defined?(:empty?)
  Dir.class_eval do
    # returns true if directory at path is empty. Ignores .svn directory
    def self.empty?(dir_path)
      (Dir.entries(dir_path)-['.','..','.svn']).empty?
    end
  end
end