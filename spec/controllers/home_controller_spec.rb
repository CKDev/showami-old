require "rails_helper"

describe HomeController do

  it "should redirect to the after_sign_in_path for a signed in user" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    sign_in @user
    get :index
    expect(response).to redirect_to users_buyers_requests_path
  end

  it "should show the home page if not signed in" do
    get :index
    expect(response).to have_http_status(:success)
  end

end
