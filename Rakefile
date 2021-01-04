# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
$:.unshift("~/.rubymotion/rubymotion-templates") # Add this line
require 'motion/project/template/ios'
require "bundler/gem_tasks"
require "bundler/setup"
Bundler.require :default

$:.unshift("./lib/")
require './lib/afmotion'

require 'webstub'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AFMotion'
  app.deployment_target = "10.0"
end
