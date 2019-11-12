class AddMaxAndMinToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :max, :integer
    add_column :logs, :min, :integer
  end
end
