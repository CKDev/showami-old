class CreateEventLogs < ActiveRecord::Migration
  def change
    create_table :event_logs do |t|
      t.integer :user_id
      t.integer :showing_id
      t.string :tags
      t.integer :level
      t.text :details
      t.timestamps null: false
    end
  end
end
