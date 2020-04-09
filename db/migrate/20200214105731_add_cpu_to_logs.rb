class AddCpuToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :cpu, :jsonb
  end
end
