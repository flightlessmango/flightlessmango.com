class AddPercentile97ToActiveStorageAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_attachments, :percentile97, :float
  end
end
