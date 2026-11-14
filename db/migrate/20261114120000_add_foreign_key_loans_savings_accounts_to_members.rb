class AddForeignKeyLoansSavingsAccountsToMembers < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key "loans", "members"
    add_foreign_key "savings_accounts", "members"
  end
end
