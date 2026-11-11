class CreateMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :members do |t|
      t.string :member_id
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
