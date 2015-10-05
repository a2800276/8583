lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "iso8583/version"
 
Gem::Specification.new do |s|
  s.name         = "iso8583"
  s.version      = ISO8583::VERSION
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['see AUTHORS']
  s.email        = ['tim.becker@kuriositaet.de']
 
  s.homepage     = 'http://github.com/a2800276/8583/'
 
  s.summary      = 'ISO 8583 financial messaging'
  s.description  = 'Ruby implementation of ISO 8583 financial messaging'
 
  s.has_rdoc     = true

  s.add_development_dependency("rake")
  s.add_dependency('test-unit', '~> 3.0.0')

  s.files        = Dir.glob("{lib,test,spec}/**/*") + %w(AUTHORS CHANGELOG LICENSE README.md TODO)
  s.require_path = 'lib'
end

