module SimpleAttachments::MigrationHelpers

  # Create attachment model columns

  def attachment
    column(:filepath, :string, :null => false)
    column(:mimetype, :string, :null => false)
    column(:filename, :string, :null => false)
    column(:filesize, :integer, :null => false)
  end

end

class ActiveRecord::ConnectionAdapters::TableDefinition # :nodoc:
  include SimpleAttachments::MigrationHelpers
end