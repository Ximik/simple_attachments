require 'spec_helper'

describe 'avatar', :type => :request, :js => true do

  def test_img(avatar)
    find('img')[:src].should match /\/avatars\/#{avatar.id}$/
  end

  let(:user) { User.create }
  before(:each) { visit edit_user_path(user) }

  it 'should not be auto associated' do
    within '.edit_user' do
      attach_sample :jpg
      avatar = Avatar.last
      test_img avatar
      avatar.user.should == nil
    end
  end

  it 'should not be replaced by an invalid file' do
    within '.edit_user' do
      attach_sample :jpg
      avatar = Avatar.last
      attach_sample :pdf
      test_img avatar
    end
  end
  
  it 'should be associated after submit' do
    within '.edit_user' do
      attach_sample :jpg
      avatar = Avatar.last
      click_button 'Update User'
      test_img avatar
      attach_sample :jpg
      new_avatar = Avatar.last
      click_button 'Update User'
      test_img new_avatar
      Avatar.exists?(avatar).should == false
    end
  end
  
  it 'should allow asynchronous upload' do
    Avatar.destroy_all
    within '.edit_user' do
      5.times { attach_sample :jpg, 0 }
      attach_sample :png
      click_button 'Update User'
      user.avatar.mimetype.should == 'image/png'
    end
  end

end
