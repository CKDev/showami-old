require "rails_helper"

describe Showing do

  context "validations" do

    it "should initially be valid" do
      @showing = FactoryGirl.build(:showing)
      expect(@showing.valid?).to be true
    end

    it "should require a showing date" do
      @showing = FactoryGirl.build(:showing, showing_at: "")
      expect(@showing.valid?).to be false
    end

    it "should not allow a showing time to be in the past" do
      @showing = Showing.new(showing_at: Time.zone.now - 1.minute)
      expect(@showing.valid?).to be false
    end

    it "should require a buyer name" do
      @showing = FactoryGirl.build(:showing, buyer_name: "")
      expect(@showing.valid?).to be false
    end

    it "should require a buyer phone" do
      @showing = FactoryGirl.build(:showing, buyer_phone: "")
      expect(@showing.valid?).to be false
    end

    it "should require a buyer type" do
      @showing = FactoryGirl.build(:showing, buyer_type: "")
      expect(@showing.valid?).to be false
    end

  end

end
