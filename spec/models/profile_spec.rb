require File.dirname(__FILE__) + '/../spec_helper'

describe Profile do
  before(:each) do
    @profile = Profile.new
  end

  it "should be valid" do
    @profile.should be_valid
  end
end
