class AddIndexesAndTriggers < ActiveRecord::Migration[8.1]
  def change
    # --- Users ---
    add_index :users, :email, unique: true, if_not_exists: true
    add_index :users, :public_id, unique: true, if_not_exists: true

    # --- Clients ---
    add_index :clients, :client_id, unique: true, if_not_exists: true
    add_index :clients, :public_id, unique: true, if_not_exists: true

    # --- SavingsAccounts ---
    add_index :savings_accounts, :client_id, if_not_exists: true
    add_index :savings_accounts, :public_id, unique: true, if_not_exists: true

    # --- Loans ---
    add_index :loans, :client_id, if_not_exists: true
    add_index :loans, :public_id, unique: true, if_not_exists: true

    # --- SavingsTransactions ---
    add_index :savings_transactions, :savings_account_id, if_not_exists: true
    add_index :savings_transactions, :public_id, unique: true, if_not_exists: true

    # --- LoanRepayments ---
    add_index :loan_repayments, :loan_id, if_not_exists: true
    add_index :loan_repayments, :public_id, unique: true, if_not_exists: true

    # --- GroupAccounts ---
    add_index :group_accounts, :public_id, unique: true, if_not_exists: true

    # --- GroupTransactions ---
    add_index :group_transactions, :group_account_id, if_not_exists: true
    add_index :group_transactions, :public_id, unique: true, if_not_exists: true

    # --- SystemConfigs ---
    add_index :system_configs, :config_key, unique: true, if_not_exists: true
    add_index :system_configs, :config_type, if_not_exists: true

    # --- SyncStates ---
    add_index :sync_states, :device_id, unique: true, if_not_exists: true

    # --- SyncOutboxes ---
    add_index :sync_outboxes, :record_type, if_not_exists: true
    add_index :sync_outboxes, :changed_at, if_not_exists: true

    # --- AuditLogs ---
    add_index :audit_logs, :user_id, if_not_exists: true
    add_index :audit_logs, :public_id, unique: true, if_not_exists: true
  end
end
