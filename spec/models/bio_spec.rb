require File.dirname(__FILE__) + '/../spec_helper'

describe Bio do
  before(:each) do
    @bio = Bio.new
  end

  it "should be valid" do
    @bio.should be_valid
  end
end
