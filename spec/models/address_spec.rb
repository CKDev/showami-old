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

  context "#single_line" do

    before :each do
      @address = FactoryGirl.create(:address)
    end

    it "has a method to print itself in one line" do
      expect(@address.single_line).to eq "600 S Broadway Unit 200 Denver, CO 80209"
    end

    it "should print correctly if no line2 is available" do
      @address.line2 = ""
      expect(@address.single_line).to eq "600 S Broadway Denver, CO 80209"
    end

  end

end
