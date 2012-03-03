class Avatar < ActiveRecord::Base
  attached_to :user
  validates_mimetype %w(image/png image/gif image/jpeg)
  validates_filesize :less_than_or_equal_to => 5e4
end