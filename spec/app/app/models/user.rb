class User < ActiveRecord::Base
  has_one_attachment :avatar, :dependent => :destroy
  has_many_attachments :books, :dependent => :destroy
end