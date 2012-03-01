class CreateAvatars < ActiveRecord::Migration
  def change
    create_table :avatars do |t|
      t.references :user, :null => true 
      t.attachment
    end
  end
end
