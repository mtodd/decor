require 'spec_helper'

class Resource < Struct.new(:name, :value, :multi)
  include Decor
  
  module V1
    def computed
      value * multi
    end
  end
  
  module V2
    MUTLI = 10
    def name
      super.upcase
    end
    def computed
      value * multi * MUTLI
    end
  end
  
  version "v3" do
    def name
      @name.reverse
    end
    def computed
      value / multi
    end
  end
  
  version "v4" do
    def name
      "%s (%s)" % [super, foo]
    end
    def computed
      nil
    end
  end
  
end

describe "decor" do
  subject{ Resource.new(@name, @value, @multi).for(@version, @options) }
  before{ @name = "foo"; @value = 2; @multi = 2 }
  
  it "should delegate to the object" do
    subject.name.should == "foo"
  end
  
  describe "v1" do
    before{ @version = "v1" }
    it "should decorate the resource with version 1 functionality" do
      subject.name.should     == @name
      subject.computed.should == @value * @multi
    end
  end
  
  describe "v2" do
    before{ @version = "v2" }
    it "should decorate the resource with version 2 functionality" do
      subject.name.should     == @name.upcase
      subject.computed.should == @value * @multi * Resource::V2::MUTLI
    end
  end
  
  describe "v3" do
    before{ @version = "v3" }
    it "should decorate the resource with version 3 functionality" do
      subject.name.should     == @name.reverse
      subject.computed.should == @value / @multi
    end
  end
  
  describe "v4" do
    before{ @version = "v4"; @options = {:foo => :bar} }
    it "should decorate the resource with version 4 functionality" do
      subject.name.should     == "%s (%s)" % [@name, @options[:foo]]
      subject.computed.should == nil
    end
  end
  
end
