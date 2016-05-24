class UpdateProfileDefaultToBothAgentType < ActiveRecord::Migration
  def change
    change_column :profiles, :agent_type, :integer, default: 2
  end
end
