class CreateGroupTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :group_transactions do |t|
      t.references :group_account, null: false, foreign_key: true
      t.decimal :amount
      t.string :transaction_type
      t.uuid :public_id
      t.integer :lock_version
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
