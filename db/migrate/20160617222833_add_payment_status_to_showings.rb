class AddPaymentStatusToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :payment_status, :integer, default: 0
  end
end
