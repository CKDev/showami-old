class AddShowingAgentIdToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :showing_agent_id, :integer
  end
end
