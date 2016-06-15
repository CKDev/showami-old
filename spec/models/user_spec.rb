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

  context "#sellers_agents" do

    it "should return users whose agent_type is either showing assistent or both" do
      @user1 = FactoryGirl.create(:user_with_valid_profile)
      @user2 = FactoryGirl.create(:user_with_valid_profile)
      @user3 = FactoryGirl.create(:user_with_valid_profile)
      @user1.profile.update(agent_type: "buyers_agent")
      @user2.profile.update(agent_type: "sellers_agent")
      @user3.profile.update(agent_type: "both")
      expect(User.sellers_agents).to contain_exactly @user2, @user3
    end

  end

  context "#not_self" do

    it "should return users that aren't the passed in id" do
      @user1 = FactoryGirl.create(:user_with_valid_profile)
      @user2 = FactoryGirl.create(:user_with_valid_profile)
      expect(User.not_self(@user1.id)).to contain_exactly @user2
    end

  end

  context "#notify_new_showing" do

    it "should call the background worker with the correct parameters" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @showing = FactoryGirl.create(:showing)
      expect { @user.notify_new_showing(@showing) }.to change { Sidekiq::Worker.jobs.size }.by(1)
    end
  end

  context "#admin?" do

    it "should properly determine if a user is an admin" do
      @user = FactoryGirl.create(:user)
      @admin = FactoryGirl.create(:admin)
      expect(@user.admin?).to be false
      expect(@admin.admin?).to be true
    end

  end

  context "#can_create_showing?" do

    it "should allow a user to create a showing if their profile is valid, they have a cc token on file, and they aren't blocked" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(cc_token: "something")
      expect(@user.can_create_showing?).to be true
    end

    it "should not allow a user to create a showing if their profile isn't valid" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(cc_token: "something")
      @user.profile.first_name = ""
      @user.profile.save(validate: false)
      expect(@user.profile.valid?).to be false
      expect(@user.can_create_showing?).to be false
    end

    it "should not allow a user to create a showing if they don't have a cc token on file" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(cc_token: nil)
      expect(@user.can_create_showing?).to be false
    end

    it "should not allow a user to create a showing if they have been marked as blocked" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.update(blocked: true)
      expect(@user.can_create_showing?).to be false
    end

  end

  context "#can_accept_showing?" do

    it "should allow a user to accept a showing if their profile is valid, they have a valid bank transfer token on file, and they aren't blocked" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      expect(@user.can_accept_showing?).to be true
    end

    it "should not allow a user to accept a showing if their profile isn't valid" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.first_name = ""
      @user.profile.save(validate: false)
      expect(@user.profile.valid?).to be false
      expect(@user.can_accept_showing?).to be false
    end

    it "should not allow a user to accept a showing if they don't have a bank transfer token" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(bank_token: nil)
      expect(@user.can_accept_showing?).to be false
    end

    it "should not allow a user to accept a showing if they have been marked as blocked" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.update(blocked: true)
      expect(@user.can_accept_showing?).to be false
    end

  end

  context "#valid_credit_card?" do

    it "should return if the user has a cc on file" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(cc_token: nil)
      expect(@user.valid_credit_card?).to be false

      @user.profile.update(cc_token: "something")
      expect(@user.valid_credit_card?).to be true
    end

  end

  context "#valid_bank_token?" do

    it "should return if the user has a valid bank key on file" do
      @user = FactoryGirl.create(:user_with_valid_profile)
      @user.profile.update(bank_token: nil)
      expect(@user.valid_bank_token?).to be false

      @user.profile.update(bank_token: "something")
      expect(@user.valid_bank_token?).to be true
    end

  end

  context "#to_s" do

    it "should return the name and email of a user" do
      @user = FactoryGirl.create(:user_with_valid_profile, email: "a@a.com")
      expect("#{@user}").to eq "Alejandro Brinkster (a@a.com)"
    end

  end

end
