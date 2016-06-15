require "rails_helper"

describe Address do

  context "validations" do

    before :each do
      @address = FactoryGirl.create(:address)
    end

    it "should be initially valid" do
      expect(@address.valid?).to be true
    end

    it "should require the street" do
      @address.update(line1: "")
      expect(@address.valid?).to be false
    end

    it "should require the city" do
      @address.update(city: "")
      expect(@address.valid?).to be false
    end

    it "should require the state" do
      @address.update(state: "")
      expect(@address.valid?).to be false
    end

    it "should only allow 2 character state values" do
      @address.update(state: "CO")
      expect(@address.valid?).to be true

      @address.update(state: "Colorado")
      expect(@address.valid?).to be false

      @address.update(state: "COL")
      expect(@address.valid?).to be false

      @address.update(state: "12")
      expect(@address.valid?).to be false
    end

    it "should require the zip" do
      @address.update(zip: "")
      expect(@address.valid?).to be false
    end

    it "should only allow 5 digit zip codes" do
      @address.update(zip: "80209")
      expect(@address.valid?).to be true

      @address.update(zip: "ASDFA")
      expect(@address.valid?).to be false

      @address.update(zip: "8020")
      expect(@address.valid?).to be false

      @address.update(zip: "802102")
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

    it "should return nil if one of the required fields is blank" do
      expect(Address.new.single_line).to be nil
    end

  end

end
