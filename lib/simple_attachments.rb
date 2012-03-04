# :main: README.rdoc

module SimpleAttachments # :nodoc:
end

dir = File.expand_path(File.dirname(__FILE__)) # :nodoc:
I18n.load_path << File.join(dir, '..', 'locales', 'en.yml')
Rails.application.config.assets.paths << File.join(dir, '..', 'assets')

require File.join(dir, 'simple_attachments', 'attachment_model')
require File.join(dir, 'simple_attachments', 'container_model')
require File.join(dir, 'simple_attachments', 'attachments_controller')
require File.join(dir, 'simple_attachments', 'view_helpers')
require File.join(dir, 'simple_attachments', 'migration_helpers')
