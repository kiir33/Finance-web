class AddPublicIdToSystemConfigs < ActiveRecord::Migration[8.1]
  def change
    add_column :system_configs, :public_id, :uuid
  end
end
