class CreateSystemConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :system_configs do |t|
      t.string :config_key
      t.string :config_value
      t.string :config_type
      t.string :description
      t.integer :lock_version

      t.timestamps
    end
  end
end
