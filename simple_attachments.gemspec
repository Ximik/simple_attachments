# encoding: UTF-8

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'simple_attachments'
  s.version      = '0.1.0'
  s.author       = 'Alex Tsokurov'
  s.email        = 'me@ximik.net'
  s.summary      = 'File attachments solution for Ruby on Rails 3'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.6'
  s.add_development_dependency 'rspec'

  s.files = Dir.glob('lib/**/*') + %w(MIT-LICENSE README.rdoc)
  s.test_files = Dir.glob('spec/**/*')
  s.require_paths = %w(lib)
end