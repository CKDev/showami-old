class AddStatusToShowing < ActiveRecord::Migration
  def change
    add_column :showings, :status, :integer, default: 0
  end
end
