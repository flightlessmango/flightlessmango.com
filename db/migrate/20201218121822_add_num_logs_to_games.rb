class AddNumLogsToGames < ActiveRecord::Migration[6.0]
  def change
    add_column :games, :num_logs, :int
  end
end
