require File.dirname(__FILE__) + '/../spec_helper'

describe Moderatorship do
  before(:each) do
    @moderatorship = Moderatorship.new
  end

  it "should be valid" do
    @moderatorship.should be_valid
  end
end
