class UpdateNameOfShowingTime < ActiveRecord::Migration
  def change
    remove_column :showings, :showing_date, :datetime
    add_column :showings, :showing_at, :datetime
  end
end
