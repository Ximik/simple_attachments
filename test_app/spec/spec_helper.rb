ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'

include Rails.application.routes.url_helpers

module JsModule

  DIR = File.expand_path(File.dirname(__FILE__))

  def attach_sample(sample)
    attach_file 'file', File.join(DIR, 'samples', "sample.#{sample}")
    sleep 2
  end

end

RSpec.configure do |c|
  c.include JsModule, :js => true
end