require 'spec_helper'

class Resource < Struct.new(:name, :value, :multi)
  include Decor
  
  # Module method
  module V1
    def computed
      value * multi
    end
  end
  version "v1" => V1
  
  # Module method, non-standard
  module Version2
    MUTLI = 10
    def name
      super.upcase
    end
    def computed
      value * multi * MUTLI
    end
  end
  # mutliple aliases
  version "v2"          => Version2,
          "v2010-10-08" => Version2
  
  # Block method
  version "v3" do
    # modified for specific version
    def name
      super.reverse
    end
    # computed value using methods specific to this version
    def computed
      value / multi
    end
  end
  
  # Block method
  version "v4" do
    # utilizes options hash
    def name
      "%s (%s)" % [super, foo]
    end
    def computed
      nil
    end
  end
  # alias predefined version
  version "v5ooooo" => "v4"
  
end

describe "decor" do
  before{ @name = "foo"; @value = 2; @multi = 2; @options = {} }
  subject{ Resource.new(@name, @value, @multi).for(@version, @options) }
  
  it "should delegate to the object" do
    subject.name.should == "foo"
  end
  
  it "should allow version switching" do
    resource = subject
    resource.version.should == "v1"
    resource = resource.for("v2")
    resource.version.should == "v2"
    resource.name.should == @name.upcase
  end
  
  describe "v1" do
    before{ @version = "v1" }
    it "should decorate the resource with version 1 functionality" do
      subject.version.should  == "v1"
      subject.name.should     == @name
      subject.computed.should == @value * @multi
    end
  end
  
  describe "v2" do
    before{ @version = "v2" }
    it "should decorate the resource with version 2 functionality" do
      subject.version.should  == "v2"
      subject.name.should     == @name.upcase
      subject.computed.should == @value * @multi * Resource::Version2::MUTLI
    end
  end
  
  describe "v3" do
    before{ @version = "v3" }
    it "should decorate the resource with version 3 functionality" do
      subject.version.should  == "v3"
      subject.name.should     == @name.reverse
      subject.computed.should == @value / @multi
    end
  end
  
  describe "v4" do
    before{ @version = "v4"; @options = {:foo => "bar"} }
    it "should decorate the resource with version 4 functionality" do
      subject.version.should  == "v4"
      subject.name.should     == "%s (%s)" % [@name, @options[:foo]]
      subject.computed.should == nil
    end
  end
  
  describe "v5ooooo as alias for v4" do
    before{ @version = "v5ooooo"; @options = {:foo => "bar"} }
    it "should decorate the resource with version 4 functionality" do
      subject.version.should  == "v5ooooo"
      subject.name.should     == "%s (%s)" % [@name, @options[:foo]]
      subject.computed.should == nil
    end
  end
  
end
