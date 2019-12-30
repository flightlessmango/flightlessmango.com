class AddDisplayNameToActiveStorageAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_attachments, :display_name, :string
  end
end
