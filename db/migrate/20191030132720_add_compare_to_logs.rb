class AddCompareToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :compare_to, :integer
  end
end
