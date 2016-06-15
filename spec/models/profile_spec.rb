require "rails_helper"

describe Profile do

  it "should default to have both buying and selling options selected" do
    expect(Profile.new.agent_type).to eq "both"
  end

  context "validations" do

    before :each do
      @profile = FactoryGirl.create(:profile)
    end

    it "should initially be valid" do
      expect(@profile.valid?).to be true
    end

    it "should require a first name" do
      @profile.update(first_name: "")
      expect(@profile.valid?).to be false
    end

    it "should require a last name" do
      @profile.update(last_name: "")
      expect(@profile.valid?).to be false
    end

    it "should require a cell phone" do
      @profile.update(phone1: "")
      expect(@profile.valid?).to be false
    end

    it "requires the cell phone to be a ten digit number" do
      @profile.update(phone1: "7208881234")
      expect(@profile.valid?).to be true

      @profile.update(phone1: "(720) 123 - 1234")
      expect(@profile.valid?).to be true

      @profile.update(phone1: "(720)123-1234")
      expect(@profile.valid?).to be true

      @profile.update(phone1: "720.123.1234")
      expect(@profile.valid?).to be true

      @profile.update(phone1: "123456789")
      expect(@profile.valid?).to be false

      @profile.update(phone1: "12345678901")
      expect(@profile.valid?).to be false

      @profile.update(phone1: "(720)123-1234 x 1234")
      expect(@profile.valid?).to be false
    end

    it "should require an office phone" do
      @profile.update(phone2: "")
      expect(@profile.valid?).to be false
    end

    it "requires the office phone to be a ten digit number" do
      @profile.update(phone2: "7208881234")
      expect(@profile.valid?).to be true

      @profile.update(phone2: "(720) 123 - 1234")
      expect(@profile.valid?).to be true

      @profile.update(phone2: "(720)123-1234")
      expect(@profile.valid?).to be true

      @profile.update(phone2: "720.123.1234")
      expect(@profile.valid?).to be true

      @profile.update(phone2: "123456789")
      expect(@profile.valid?).to be false

      @profile.update(phone2: "12345678901")
      expect(@profile.valid?).to be false

      @profile.update(phone2: "(720)123-1234 x 1234")
      expect(@profile.valid?).to be false
    end

    it "should require a company" do
      @profile.update(company: "")
      expect(@profile.valid?).to be false
    end

    it "should require an agent id" do
      @profile.update(agent_id: "")
      expect(@profile.valid?).to be false
    end

    it "should require an agent type" do
      @profile.update(agent_type: "")
      expect(@profile.valid?).to be false
    end

  end

  context "#full_name" do

    it "should print the user's full name" do
      profile = Profile.new(first_name: "Alejandro", last_name: "Brinkster")
      expect(profile.full_name).to eq "Alejandro Brinkster"
    end

    it "should print the user's first name if the last name isn't available" do
      profile = Profile.new(first_name: "Alejandro", last_name: "")
      expect(profile.full_name).to eq "Alejandro"
    end

    it "should print the user's last name if the first name isn't available" do
      profile = Profile.new(first_name: "", last_name: "Brinkster")
      expect(profile.full_name).to eq "Brinkster"
    end

    it "should return an empty string if neither name is available" do
      profile = Profile.new(first_name: "", last_name: "")
      expect(profile.full_name).to eq ""

      profile = Profile.new(first_name: nil, last_name: nil)
      expect(profile.full_name).to eq ""
    end

  end

  context "#geo_box_coords" do

    it "should properly convert from a valid geo_box (in postgres ::box style) to an array in the geocoder gem style" do
      profile = Profile.new(geo_box: "(-104.682, 39.822), (-105.358, 39.427)")
      expect(profile.geo_box_coords).to eq [[39.427, -105.358], [39.822, -104.682]]
    end

    it "should return lat/long of 0/0 for an empty or invalid geo_box" do
      profile = Profile.new(geo_box: "")
      expect(profile.geo_box_coords).to eq [[0.0, 0.0], [0.0, 0.0]]

      profile = Profile.new(geo_box: nil)
      expect(profile.geo_box_coords).to eq [[0.0, 0.0], [0.0, 0.0]]
    end

  end

end
