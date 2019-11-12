class AddMinMaxOnePercentToActiveStorageAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_attachments, :min, :float
    add_column :active_storage_attachments, :max, :float
    add_column :active_storage_attachments, :avg, :float
    add_column :active_storage_attachments, :onepercent, :float
  end
end
