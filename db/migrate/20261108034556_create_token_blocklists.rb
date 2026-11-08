class CreateTokenBlocklists < ActiveRecord::Migration[8.1]
  def change
    create_table :token_blocklists do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false
      t.references :user, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
    add_index :token_blocklists, :jti, unique: true
    add_index :token_blocklists, :exp
  end
end