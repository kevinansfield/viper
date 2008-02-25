require File.dirname(__FILE__) + '/../spec_helper'

describe Friendship do
  before(:each) do
    @friendship = Friendship.new
  end

  it "should be valid" do
    @friendship.should be_valid
  end
end
