class CreateSyncStates < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_states do |t|
      t.string :device_id
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
