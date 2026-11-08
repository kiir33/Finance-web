class CreateGroupAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :group_accounts do |t|
      t.decimal :cash_balance
      t.decimal :bank_balance
      t.uuid :public_id
      t.integer :lock_version
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
