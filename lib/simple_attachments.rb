module SimpleAttachments # :nodoc:
end

DIR = Dir.pwd
I18n.load_path << File.join(DIR, '..', 'locales', 'en.yml')
Rails.application.config.assets.paths << File.join(DIR, '..', 'assets')

require 'simple_attachments/attachment_model'
require 'simple_attachments/container_model'
require 'simple_attachments/attachments_controller'
require 'simple_attachments/view_helpers'
require 'simple_attachments/migration_helpers'