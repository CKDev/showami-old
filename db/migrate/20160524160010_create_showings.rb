class CreateShowings < ActiveRecord::Migration
  def change
    create_table :showings do |t|
      t.datetime :showing_date
      t.string :mls
      t.text :notes
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
