class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.json :raw_body
      t.string :event_type

      t.timestamps null: false
    end
  end
end
