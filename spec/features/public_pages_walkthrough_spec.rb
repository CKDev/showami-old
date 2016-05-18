require "feature_helper"

feature "A guest user" do

  scenario "can view every public page" do
    visit root_path
  end

end
