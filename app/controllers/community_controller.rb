class CommunityController < ApplicationController
  
  before_filter :setup_maincols

  def index
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("")
    if params[:id]
      @initial = params[:id]
      profiles = Profile.find(:all,
                              :conditions => ["last_name like ?", @initial+'%'],
                              :order => "last_name, first_name")
      @users = profiles.collect { |profile| profile.user }
    end
  end

  def browse
    
  end

  def search
    
  end
  
  private
  
  def setup_maincols
    self.maincol_one = nil
    self.maincol_two = nil
  end
end
