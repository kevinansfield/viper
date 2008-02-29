class Bio < ActiveRecord::Base
  belongs_to :user
  
  after_initialize :clear_text_fields
  
  QUESTIONS = %w(about interests music films television books heroes)
  # A constant for everything except the bio
  FAVORITES = QUESTIONS - %w(about author_about)
  
  acts_as_ferret :remote => false
  acts_as_textiled :about, :interests, :music, :films, :television, :books, :heroes
  
  validates_length_of QUESTIONS, :maximum => 65000
  validates_length_of :author_about, :maximum => 1000
                       
  private
  
  def clear_text_fields
    QUESTIONS.each do |question|
      self[question] ||=  ""
    end
  end
  
end
