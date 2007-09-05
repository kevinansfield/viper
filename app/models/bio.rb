class Bio < ActiveRecord::Base
  belongs_to :user
  
  QUESTIONS = %w(about interests music films television books heroes)
  
  validates_length_of QUESTIONS,
                      :maximum => 65000
                      
  # A constant for everything except the bio
  FAVORITES = QUESTIONS - %w(about)
  
  def initialize
    super
    QUESTIONS.each do |question|
      self[question] = ""
    end
  end
end
