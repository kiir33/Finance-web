class AddDeletedAtToSystemConfigs < ActiveRecord::Migration[8.1]
  def change
    add_column :system_configs, :deleted_at, :datetime
    add_index :system_configs, :deleted_at
  end
end
