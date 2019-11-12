class AddTitleAndTextToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :title, :text
    add_column :logs, :text, :text
  end
end
