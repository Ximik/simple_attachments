require 'spec_helper'

describe 'documents', :type => :request, :js => true do

  let(:user) { User.create }
  before(:each) do
    Document.destroy_all
    visit edit_user_path(user)
  end

  it 'should be auto associated' do
    within '.simple_attachments_multiple_div' do
      attach_sample :pdf
      user.documents.count.should == 1
    end
  end

  it 'should not show field with invalid file' do
    within '.edit_user' do
      attach_sample :jpg
      page.should have_selector('.simple_attachments_field_div')
    end
  end
  
  it 'should allow asynchronous upload and destroy' do
    within '.simple_attachments_multiple_div' do
      5.times { attach_sample :pdf, 0 }
      attach_sample :pdf
      3.times { find('.simple_attachments_destroy_link').click }
      attach_sample :pdf, 0
      attach_sample :pdf
      user.documents.count.should == 5
    end
  end

end
