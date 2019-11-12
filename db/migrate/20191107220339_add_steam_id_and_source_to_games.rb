class AddSteamIdAndSourceToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :steamid, :integer
    add_column :games, :source, :string
    add_column :games, :image_url, :string
  end
end
