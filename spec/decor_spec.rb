require 'spec_helper'

require 'models/bare'

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
  
end
