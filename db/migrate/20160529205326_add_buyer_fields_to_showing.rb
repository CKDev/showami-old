class AddBuyerFieldsToShowing < ActiveRecord::Migration
  def change
    add_column :showings, :buyer_name, :string
    add_column :showings, :buyer_phone, :string
    add_column :showings, :buyer_type, :integer
  end
end
