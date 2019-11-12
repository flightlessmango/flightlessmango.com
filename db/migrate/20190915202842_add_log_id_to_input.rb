class AddLogIdToInput < ActiveRecord::Migration[6.0]
  def change
    add_column :inputs, :log_id, :integer
  end
end
