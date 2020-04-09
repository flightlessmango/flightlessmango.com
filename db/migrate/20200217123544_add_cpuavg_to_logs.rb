class AddCpuavgToLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :cpuavg, :jsonb
  end
end
