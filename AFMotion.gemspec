# -*- encoding: utf-8 -*-
require File.expand_path('../lib/afmotion/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "afmotion"
  s.version     = AFMotion::VERSION
  s.authors     = ["Clay Allsopp"]
  s.email       = ["clay.allsopp@gmail.com"]
  s.homepage    = "https://github.com/clayallsopp/AFMotion"
  s.summary     = "A RubyMotion Wrapper for AFNetworking"
  s.description = "A RubyMotion Wrapper for AFNetworking"
  s.license = 'MIT'

  s.files         = `git ls-files`.split($\).delete_if {|x| x.include? "example"}
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency "motion-cocoapods", ">= 1.9.1"
  s.add_dependency "motion-require", ">= 0.1"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'webstub', "~> 1.1.6"
end
