class CreateLoans < ActiveRecord::Migration[8.1]
  def change
    create_table :loans do |t|
      t.bigint :member_id, null: false
      t.uuid :public_id
      t.integer :lock_version
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
