class AddLutrisIdToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :lutris_id, :int
  end
end
