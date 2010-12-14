require 'spec_helper'

require 'models/resource'

describe Decor::Base do
  before{ @version = "v1"; @name = "foo"; @value = 2; @multi = 2; @options = {} }
  subject{ Resource.new(@name, @value, @multi).for(@version, @options) }
  
  it "should delegate to the object" do
    subject.name.should == @name
  end
  
  it "should allow version switching" do
    resource = subject
    resource.version.should == "v1"
    resource = resource.for("v2")
    resource.version.should == "v2"
    resource.name.should == @name.upcase
  end
  
  it "should allow overriding the module for the version" do
    v2 = Module.new
    resource = subject.for("v1", :module => v2)
    resource.should be_a(v2)
  end
  
  describe "v1" do
    before{ @version = "v1" }
    
    it "should delegate to the target for original values" do
      subject.name.should == @name
    end
    
    it "should allow computed values" do
      subject.computed.should == @value * @multi
    end
  end
  
  describe "v2" do
    before{ @version = "v2" }
    
    it "should allow modified versions of methods in the target" do
      subject.name.should == @name.upcase
    end
    
    it "should allow constants in the context of the version" do
      subject.computed.should == @value * @multi * Resource::Version2::MUTLI
    end
    
  end
  
  describe "v2010-12-08" do
    before{ @version = "v2010-12-08" }
    
    it "should keep the name of the alias as the version" do
      subject.version.should == "v2010-12-08"
    end
    
    it "should be the same as its alias" do
      subject.should be_a(subject.target.class.version("v2"))
    end
  end
  
  describe "v3" do
    before{ @version = "v3"; @options = {:foo => "bar"} }
    
    it "should use values in the context hash as methods" do
      subject.name.should == "%s (%s)" % [@name, @options[:foo]]
    end
  end
  
end
