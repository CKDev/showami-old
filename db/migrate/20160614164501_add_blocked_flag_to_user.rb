class AddBlockedFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :blocked, :boolean, default: false
  end
end
