class CreateApisBenches < ActiveRecord::Migration[6.0]
  def change
    create_table :apis_benches do |t|
      t.integer :bench_id
      t.integer :api_id
      t.jsonb :fps
      t.jsonb :frametime
      t.jsonb :full_fps
      t.jsonb :full_frametime
      t.jsonb :bar
      
      t.timestamps
    end
  end
end
