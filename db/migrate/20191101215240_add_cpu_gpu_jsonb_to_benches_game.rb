class AddCpuGpuJsonbToBenchesGame < ActiveRecord::Migration[6.0]
  def change
    add_column :benches_games, :cpu, :jsonb
    add_column :benches_games, :gpu, :jsonb
  end
end
