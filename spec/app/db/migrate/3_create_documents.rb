class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :avatar, :null => true 
      t.attachment
    end
  end
end