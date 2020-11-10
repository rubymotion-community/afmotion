require "afmotion/version"
require 'motion-cocoapods'
require 'motion-require'

unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Require.all(Dir.glob(File.join(File.dirname(__FILE__), 'afmotion/**/*.rb')))

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'afmotion/**/*.rb')).each do |file|
    if app.respond_to?("exclude_from_detect_dependencies")
      app.exclude_from_detect_dependencies << file
    end
  end

  app.pods do
    pod 'AFNetworking', '~> 4.0.0'
  end
end
