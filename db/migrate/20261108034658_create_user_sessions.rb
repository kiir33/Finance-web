class CreateUserSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.string :token_digest, null: false
      t.string :ip_address
      t.string :user_agent
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :user_sessions, :token_digest, unique: true
    add_index :user_sessions, :expires_at
    add_index :user_sessions, [ :user_id, :created_at ]
  end
end
