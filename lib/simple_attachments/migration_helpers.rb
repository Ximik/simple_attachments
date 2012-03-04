module SimpleAttachments::MigrationHelpers

  # Create attachment model columns

  def attachment
    column(:filename, :string, :null => false)
    column(:mimetype, :string, :null => false)
    column(:filesize, :integer, :null => false)
    column(:filepath, :string, :null => false)
  end

end

ActiveRecord::ConnectionAdapters::TableDefinition.send :include, SimpleAttachments::MigrationHelpers
