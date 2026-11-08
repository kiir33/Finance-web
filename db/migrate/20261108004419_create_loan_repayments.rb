class CreateLoanRepayments < ActiveRecord::Migration[8.1]
  def change
    create_table :loan_repayments do |t|
      t.references :loan, null: false, foreign_key: true
      t.decimal :amount
      t.uuid :public_id
      t.integer :lock_version
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
