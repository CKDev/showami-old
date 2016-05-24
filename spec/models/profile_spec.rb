require "rails_helper"

describe Profile do

  it "should default to have both buying and selling options selected" do
    expect(Profile.new.agent_type).to eq "both"
  end

  context "validations" do

    it "should require a first name" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(first_name: "")
      expect(@profile.valid?).to be false
    end

    it "should require a last name" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(last_name: "")
      expect(@profile.valid?).to be false
    end

    it "should require a cell phone" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(phone1: "")
      expect(@profile.valid?).to be false
    end

    it "should require an office phone" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(phone2: "")
      expect(@profile.valid?).to be false
    end

    it "should require a company" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(company: "")
      expect(@profile.valid?).to be false
    end

    it "should require an agent id" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(agent_id: "")
      expect(@profile.valid?).to be false
    end

    it "should require an agent type" do
      @profile = FactoryGirl.create(:profile)
      expect(@profile.valid?).to be true
      @profile.update(agent_type: "")
      expect(@profile.valid?).to be false
    end

  end

  context "#greeting" do

    it "should print the user's first name, if known" do
      profile = Profile.new(first_name: "Alejandro")
      expect(profile.greeting).to eq "Hi, Alejandro!"
    end

    it "should print a generic greeting, if the user's name isn't known" do
      profile = Profile.new(first_name: "Alejandro")
      expect(profile.greeting).to eq "Hi, Alejandro!"
    end

  end

end
