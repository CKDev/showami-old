require "rails_helper"

describe User do

  it "should list showings in descending date order" do
    @user = FactoryGirl.create(:user_with_valid_profile)
    @showing1 = FactoryGirl.create(:showing)
    @showing2 = FactoryGirl.create(:showing)
    @showing3 = FactoryGirl.create(:showing)
    @showing1.showing_at = Time.zone.now - 1.month
    @showing2.showing_at = Time.zone.now + 1.month
    @showing3.showing_at = Time.zone.now + 1.day
    @showing1.save(validate: false)
    @showing2.save(validate: false)
    @showing3.save(validate: false)
    @user.showings << [@showing1, @showing2, @showing3]
    expect(@user.showings.first).to eq @showing2
    expect(@user.showings.second).to eq @showing3
    expect(@user.showings.third).to eq @showing1
  end

end
