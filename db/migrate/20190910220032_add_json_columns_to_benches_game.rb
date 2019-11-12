class AddJsonColumnsToBenchesGame < ActiveRecord::Migration[6.0]
  def change
    add_column :benches_games, :fps, :jsonb
    add_column :benches_games, :frametime, :jsonb
    add_column :benches_games, :full_fps, :jsonb
    add_column :benches_games, :full_frametime, :jsonb
    add_column :benches_games, :bar, :jsonb
  end
end
