class AddTypeToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :type, :string
  end
end
