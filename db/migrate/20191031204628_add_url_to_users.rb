class AddUrlToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :url, :string
  end
end
