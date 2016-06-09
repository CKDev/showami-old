class AddStripeTokenToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :cc_token, :string
    add_column :profiles, :bank_token, :string
  end
end
