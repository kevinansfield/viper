class Profile < ActiveRecord::Base
  belongs_to :user
  acts_as_ferret :remote => false
  
  acts_as_mappable
  before_validation_on_create :geocode_address
  before_validation_on_update :geocode_address
  
  ALL_FIELDS = %w(first_name last_name gender birthdate occupation city county post_code)
  STRING_FIELDS = %w(first_name last_name occupation county post_code)
  VALID_GENDERS = ["Male", "Female"]
  START_YEAR = 1900
  VALID_DATES = DateTime.new(START_YEAR)..DateTime.now
  
  validates_length_of STRING_FIELDS,
                      :maximum => 255
                      
  validates_inclusion_of :gender,
                         :in => VALID_GENDERS,
                         :allow_nil => true,
                         :message => "must be male or female"
                         
  validates_inclusion_of :birthdate,
                         :in => VALID_DATES,
                         :allow_nil => true,
                         :message => "is invalid"
                         
  validates_format_of    :post_code,
                         :with => /^$|^(GIR 0AA|[A-PR-UWYZ]([0-9]{1,2}|([A-HK-Y][0-9]|[A-HK-Y][0-9]([0-9]|[ABEHMNPRV-Y]))|[0-9][A-HJKS-UW]) [0-9][ABD-HJLNP-UW-Z]{2}$|^\d{5}$|^\d{5}-\d{4}$)/i,
                         :message => "must be a valid UK post code or US zip code"
  
  # Return the full name (first plus last).
  def full_name
    if !first_name.blank? || !last_name.blank?
      [first_name, last_name].join(" ").strip
    else
      nil
    end
  end

  # Return a sensibly formatted location string.
  def location
    [city, county, post_code].join(" ").strip
  end
  
  # Return the age using the birthdate
  def age
    return if birthdate.nil?
    today = Date.today
    (today.year - birthdate.year) + ((today.month - birthdate.month) + ((today.day - birthdate.day) < 0 ? -1 : 0) < 0 ? -1 : 0)
  end
  
  # Find by age, sex, location distance
  def self.find_by_asl(params)
    where = []
    # Set up the age restrictions as birthdate range limits in SQL
    unless params[:min_age].blank?
      where << "ADDDATE(birthdate, INTERVAL :min_age YEAR) < CURDATE()"
    end
    unless params[:max_age].blank?
      where << "ADDDATE(birthdate, INTERVAL :max_age+1 YEAR) > CURDATE()"
    end
    # Set up the gender restriction in SQL
    where << "gender = :gender" unless params[:gender].blank?
    if where.empty?
      unless params[:miles].blank? || params[:post_code].blank?
        find(:all,
             :origin => params[:post_code],
             :within => params[:miles],
             :order => "last_name, first_name")
      else
        []
      end
    else
      unless params[:miles].blank? || params[:post_code].blank?
        find(:all,
             :origin => params[:post_code],
             :within => params[:miles],
             :conditions => [where.join(" AND "), params],
             :order => "last_name, first_name")
      else
        find(:all,
             :conditions => [where.join(" AND "), params],
             :order => "last_name, first_name")
      end
    end
  end
  
  private
  
    def geocode_address
      unless location.blank?
        geo = GeoKit::Geocoders::MultiGeocoder.geocode(location)
        errors.add(:address, "could not geocode address") if !geo.success
        if geo.success
          self.lat, self.lng = geo.lat, geo.lng
          self.city = geo.city unless !self.city.blank?
          self.county = geo.state unless !self.county.blank?
          self.post_code = geo.zip unless !self.post_code.blank?
        end
      end
    end
end
