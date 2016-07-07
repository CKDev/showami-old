class CreateInvitedUsers < ActiveRecord::Migration
  def change
    create_table :invited_users do |t|
      t.string :email
      t.integer :invited_by_id
      t.timestamps null: false
    end
  end
end
