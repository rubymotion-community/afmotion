# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require "bundler/gem_tasks"
require "bundler/setup"
Bundler.require :default

$:.unshift("./lib/")
require './lib/afmotion'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AFMotion'

  app.pods do
    pod "AFNetworking"
  end
end
