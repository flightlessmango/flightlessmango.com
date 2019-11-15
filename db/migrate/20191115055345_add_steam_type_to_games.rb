class AddSteamTypeToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :steam_type, :string
  end
end
