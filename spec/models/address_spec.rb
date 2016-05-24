require "rails_helper"

describe Address do

  context "validations" do

    it "should require the street" do
      @address = FactoryGirl.create(:address)
      expect(@address.valid?).to be true
      @address.update(line1: "")
      expect(@address.valid?).to be false
    end

    it "should require the city" do
      @address = FactoryGirl.create(:address)
      expect(@address.valid?).to be true
      @address.update(city: "")
      expect(@address.valid?).to be false
    end

    it "should require the state" do
      @address = FactoryGirl.create(:address)
      expect(@address.valid?).to be true
      @address.update(state: "")
      expect(@address.valid?).to be false
    end

    it "should require the zip" do
      @address = FactoryGirl.create(:address)
      expect(@address.valid?).to be true
      @address.update(zip: "")
      expect(@address.valid?).to be false
    end

  end

end
