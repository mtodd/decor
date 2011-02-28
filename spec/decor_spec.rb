require 'spec_helper'

require 'models/bare'
require 'models/resource'

describe Decor do
  
  describe "when included in a class" do
    
    describe ".version" do
      it "should be available" do
        Bare.should_not respond_to(:version)
        Bare.send(:include, Decor)
        Bare.should respond_to(:version)
      end
      
      it "should define a collection of versions" do
        Bare.versions.should respond_to(:to_hash)
      end
      
      it "should allow new versions to be defined with a block" do
        Bare.should respond_to(:version)
        Bare.version("v1"){}
        Bare.versions.key?("v1").should be_true
      end
      
      it "should allow new versions to be defined with a module" do
        v2 = Module.new
        Bare.version "v2" => v2
        Bare.versions.key?("v2").should be_true
        Bare.versions["v2"].should == v2
      end
      
      it "should return versions by name when no block or module is given" do
        v3 = Module.new
        Bare.version "v3" => v3
        Bare.version("v3").should == v3
      end
      
      it "should turn a block into a module" do
        Bare.version("v4"){}
        Bare.version("v4").should be_a(Module)
      end
    end
    
    describe "#for" do
      subject{ Bare.new }
      
      it "should decorate the object with the version specified" do
        subject.for("v1").version.should == "v1"
      end
      
      it "should target the instance" do
        subject.for("v1").target.should be_a(Bare)
        subject.for("v1").target.should == subject
      end
      
      it "should decorate with an instance of Decor::Base" do
        subject.for("v1").should be_a(Decor::Base)
      end
      
      it "should decorate by including the version module" do
        subject.for("v1").should be_a(Bare.version("v1"))
      end
      
    end
    
  end
  
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
      
      it "should be able to see the computed values from the target object" do
        subject.should be_computed
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
  
end
