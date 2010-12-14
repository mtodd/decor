$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
require 'rubygems'
require 'bundler/setup'
require 'decor'

require 'rspec'

require 'models/resource'
