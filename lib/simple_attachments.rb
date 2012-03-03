module SimpleAttachments # :nodoc:
end

DIR = File.expand_path(File.dirname(__FILE__))
I18n.load_path << File.join(DIR, '..', 'locales', 'en.yml')
Rails.application.config.assets.paths << File.join(DIR, '..', 'assets')

require File.join(DIR, 'simple_attachments', 'attachment_model')
require File.join(DIR, 'simple_attachments', 'container_model')
require File.join(DIR, 'simple_attachments', 'attachments_controller')
require File.join(DIR, 'simple_attachments', 'view_helpers')
require File.join(DIR, 'simple_attachments', 'migration_helpers')