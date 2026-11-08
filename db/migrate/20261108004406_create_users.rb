class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.integer :role
      t.uuid :public_id
      t.integer :lock_version

      t.timestamps
    end
  end
end
