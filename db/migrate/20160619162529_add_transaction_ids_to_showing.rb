class AddTransactionIdsToShowing < ActiveRecord::Migration
  def change
    add_column :showings, :charge_txn, :string
    add_column :showings, :transfer_txn, :string
  end
end
