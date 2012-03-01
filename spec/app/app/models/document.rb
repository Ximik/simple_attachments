class Document < ActiveRecord::Base
  attached_to :user
  validates_mimetype %w(application/pdf)
  validates_filesize :less_than_or_equal_to => 20e6
end