# == Schema Information
# Schema version: 47
#
# Table name: profiles
#
#  id         :integer(11)     not null, primary key
#  user_id    :integer(11)     default(0), not null
#  first_name :string(255)     
#  last_name  :string(255)     
#  gender     :string(255)     
#  birthdate  :date            
#  city       :string(255)     
#  county     :string(255)     
#  post_code  :string(255)     
#  lat        :float           
#  lng        :float           
#  occupation :string(255)     default("")
#  website    :string(255)     
#

class Profile < ActiveRecord::Base
  include ActivityLogger
  
  belongs_to :user
  has_many :im_contacts
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  acts_as_ferret :remote => false
  
  acts_as_mappable
  before_validation_on_create :geocode_address
  before_validation_on_update :geocode_address
  
  after_update :save_im_contacts
  after_save :log_activity
  
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
                         
  def im_contact_attributes=(im_contact_attributes)
    im_contact_attributes.each do |attributes|
      unless attributes[:name].blank? and attributes[:service].blank?
        if attributes[:id].blank?
          im_contacts.build(attributes)
        else
          im_contact = im_contacts.detect { |im| im.id == attributes[:id].to_i }
          im_contact.attributes = attributes
        end
      end
    end
  end
  
  def save_im_contacts
    im_contacts.each do |im_contact|
      if !im_contact.contact.blank?
        im_contact.save(false)
      elsif im_contact.contact.blank? and !im_contact.id.nil?
        im_contact.destroy
      end
    end
  end
  
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

  def log_activity
    add_activities(:item => self, :user => user)
  end
  
end
