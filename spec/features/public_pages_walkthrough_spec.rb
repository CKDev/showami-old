require "feature_helper"

feature "A guest user can visit all public pages" do

  scenario "a guest user can view every public page" do
    visit root_path
  end

end
