require "rubygems"
require "bundler/setup"
require File.dirname(__FILE__) + "/../lib/init.rb"

RSpec.configure do |config|
  # Use color in STDOUT
  config.color_enabled = true
end
