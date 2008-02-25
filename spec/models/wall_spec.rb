require File.dirname(__FILE__) + '/../spec_helper'

describe Wall do
  before(:each) do
    @wall = Wall.new
  end

  it "should be valid" do
    @wall.should be_valid
  end
end
