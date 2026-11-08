class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :client_id
      t.string :name
      t.string :phone_number
      t.string :address
      t.uuid :public_id
      t.integer :lock_version
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
