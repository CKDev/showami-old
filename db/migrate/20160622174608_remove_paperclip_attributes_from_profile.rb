class RemovePaperclipAttributesFromProfile < ActiveRecord::Migration
  def change
    remove_column :profiles, "avatar_file_name"
    remove_column :profiles, "avatar_content_type"
    remove_column :profiles, "avatar_file_size"
    remove_column :profiles, "avatar_updated_at"
  end
end
