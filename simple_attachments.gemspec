# encoding: UTF-8

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'simple_attachments'
  s.version      = '0.1.1'
  s.author       = 'Alex Tsokurov'
  s.email        = 'me@ximik.net'
  s.summary      = 'File attachments solution for Ruby on Rails 3'
  s.homepage     = 'http://github.com/Ximik/simple_attachments'

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'

  s.files      = Dir.glob(['lib/**/*', 'locales/*', 'vendor/**/*']) + %w(MIT-LICENSE README.rdoc)
  s.test_files = Dir.glob('test/**/*')

  s.has_rdoc = true
  s.extra_rdoc_files << 'README.rdoc'
end
