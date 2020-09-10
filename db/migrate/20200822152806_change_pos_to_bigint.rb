class ChangePosToBigint < ActiveRecord::Migration[6.0]
  def change
    change_column :inputs, :pos, :bigint
  end
end
