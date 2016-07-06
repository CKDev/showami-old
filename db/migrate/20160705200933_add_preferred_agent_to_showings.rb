class AddPreferredAgentToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :preferred_agent_id, :integer
  end
end
