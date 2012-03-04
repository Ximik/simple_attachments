class User < ActiveRecord::Base
  has_one_attachment :avatar, :dependent => :destroy
  has_many_attachments :documents, :dependent => :destroy
end