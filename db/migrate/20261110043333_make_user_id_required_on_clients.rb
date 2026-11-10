class MakeUserIdRequiredOnClients < ActiveRecord::Migration[8.1]
  def up
    # Backfill any remaining null user_ids with an admin user
    admin = User.find_by(role: 1)
    if admin
      Client.where(user_id: nil).update_all(user_id: admin.id)
    end

    # Make user_id non-nullable
    change_column_null :clients, :user_id, false
  end

  def down
    change_column_null :clients, :user_id, true
  end
end
