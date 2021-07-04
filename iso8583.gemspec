# -*- mode: ruby; encoding: utf-8; tab-width: 2; indent-tabs-mode: nil -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "iso8583/version"
 
Gem::Specification.new do |s|
  s.name        = "iso8583"
  s.version     = ISO8583::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tim Becker", "Slava Kravchenko"]
  s.email       = ["tim.becker@kuriositaet.de","cordawyn@gmail.com"]
  s.homepage    = "http://github.com/a2800276/8583/"
  s.summary     = "Ruby implementation of ISO 8583 financial messaging"
  s.description = "Ruby implementation of ISO 8583 financial messaging"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.required_ruby_version     = ">= 1.9"
  s.rubyforge_project         = "iso8583"
  
  s.requirements << "none"
  
  s.files        = Dir.glob("{lib,test}/**/*") + %w(AUTHORS CHANGELOG LICENSE README TODO)
  s.require_path = 'lib'

  s.add_development_dependency("rake")
  s.add_development_dependency("test-unit")
end
