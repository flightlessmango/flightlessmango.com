class AddUserIdAndGameIdToLog < ActiveRecord::Migration[6.0]
  def change
    add_column :logs, :user_id, :integer
    add_column :logs, :game_id, :integer
  end
end
