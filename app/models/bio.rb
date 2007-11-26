class Bio < ActiveRecord::Base
  belongs_to :user
  
  def after_initialize
    # TODO: Work out why just calling the method returns a method not defined error
    # clear_text_fields!
    QUESTIONS.each do |question|
      self[question] ||=  ""
    end
  end
  
  QUESTIONS = %w(about interests music films television books heroes)
  # A constant for everything except the bio
  FAVORITES = QUESTIONS - %w(about author_about)
  
  acts_as_ferret
  acts_as_textiled :about, :interests, :music, :films, :television, :books, :heroes
  
  validates_length_of QUESTIONS, :maximum => 65000
  validates_length_of :author_about, :maximum => 1000
                       
  private
  
  def clear_text_fields!
    QUESTIONS.each do |question|
      self[question] ||=  ""
    end
  end
  
end
