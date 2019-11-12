class AddApiIdToInputs < ActiveRecord::Migration[6.0]
  def change
    add_column :inputs, :apis_bench_id, :integer
    add_column :inputs, :api_id, :integer
  end
end
