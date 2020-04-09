class AddAvgcpuToBenchesGame < ActiveRecord::Migration[6.0]
  def change
    add_column :benches_games, :avgcpu, :jsonb
  end
end
