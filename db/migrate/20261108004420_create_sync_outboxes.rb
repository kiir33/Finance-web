class CreateSyncOutboxes < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_outboxes do |t|
      t.string :record_type
      t.string :record_id
      t.string :public_id
      t.datetime :changed_at
      t.boolean :deleted

      t.timestamps
    end
  end
end
