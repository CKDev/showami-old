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

  context "#in_bounding_box" do

    it "should return users whose bounding box conatins the showing point" do
      @user1 = FactoryGirl.create(:user_with_valid_profile)
      @user2 = FactoryGirl.create(:user_with_valid_profile)
      @user3 = FactoryGirl.create(:user_with_valid_profile)
      @user4 = FactoryGirl.create(:user_with_valid_profile)
      @user5 = FactoryGirl.create(:user_with_valid_profile)
      @user1.profile.update(geo_box: "(-104.800, 39.500), (-105.000, 40.000)")
      @user2.profile.update(geo_box: "(-104.901, 39.500), (-105.000, 40.000)")
      @user3.profile.update(geo_box: "(-104.800, 39.751), (-105.000, 40.000)")
      @user4.profile.update(geo_box: "(-104.800, 39.500), (-104.899, 40.000)")
      @user5.profile.update(geo_box: "(-104.800, 39.500), (-105.000, 39.749)")
      expect(User.in_bounding_box(39.750, -104.900)).to contain_exactly @user1
    end

  end

end
