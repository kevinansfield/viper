class CommunityController < ApplicationController
  
  before_filter :setup_maincols, :setup_sidebars
  
  tab :community

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
    return if params[:commit].nil?
    begin
      profiles = Profile.find_by_asl(params)
      @users = profiles.collect { |profile| profile.user }
    rescue GeoKit::Geocoders::GeocodeError
      @invalid = true
    end
  end

  def search   
    if params[:q]
      query = params[:q]
      begin
        # First find the user hits...
        @users = User.find_by_contents(query, :limit => :all)
        # ...then the subhits.
        profiles = Profile.find_by_contents(query, :limit => :all)
        bios  =  Bio.find_by_contents(query, :limit => :all)
    
        # Now combine into one list of distinct users sorted by last name.
        hits = profiles + bios
        @users.concat(hits.collect { |hit| hit.user }).uniq!
        # Sort by last name (requires a spec for each user).
        @users = @users.sort_by { |user| user.last_name }
        @users = @users.collect { |user| user unless user.activated_at.nil? }.compact
      rescue Ferret::QueryParser::QueryParseException
        @invalid = true
      end
    end
  end
  
  private
  
  def setup_maincols
    self.maincol_one = nil
    self.maincol_two = nil
  end
  
  def setup_sidebars
    self.sidebar_one = 'community/sidebar'
  end
end
