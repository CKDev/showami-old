class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :phone1
      t.string :phone2
      t.string :company
      t.string :agent_id
      t.integer :agent_type
      t.timestamps null: false
    end
  end
end
