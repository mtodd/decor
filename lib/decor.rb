module Decor
  def self.included(target)
    target.send(:extend, ClassMethods)
  end
  
  def for(version, options = {})
    version ||= "v1"
    version = self.class.const_get(version.upcase)
    decorator = Class.new(Base).new(self, options)
    decorator.send(:extend, version)
    decorator
  end
  
  class Base < Struct.new(:target, :options)
    def initialize(target, options)
      options = {} if options.nil?
      super
      options.each do |(key, value)|
        class_eval do
          attr_accessor key.to_sym
        end
        send("#{key}=", value)
      end
    end
    def method_missing(method, *args, &block)
      target.send(method, *args, &block) if respond_to?(method)
    end
    def respond_to?(method)
      target.respond_to?(method)
    end
  end
  
  module ClassMethods
    def version(version, options = {}, &block)
      # ...
    end
  end
  
end
