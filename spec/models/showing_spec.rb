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

  context "#verify_geocoding" do

    let(:valid_attributes) do
      {
        showing_at: Time.zone.now + 3.hours,
        mls: "abc123",
        notes: "notes about the showing",
        address_attributes: {
          line1: "600 S Broadway",
          line2: "Unit 200",
          city: "Denver",
          state: "CO",
          zip: "80209"
        },
        buyer_name: "Andre",
        buyer_phone: "720 999 8888",
        buyer_type: "individual"
      }
    end

    let(:invalid_attributes) do
      {
        showing_at: Time.zone.now + 3.hours,
        mls: "abc123",
        notes: "notes about the showing",
        address_attributes: {
          line1: "Doesn't Exist",
          line2: "",
          city: "Somewhere",
          state: "CO",
          zip: "12345"
        },
        buyer_name: "Andre",
        buyer_phone: "720 999 8888",
        buyer_type: "individual"
      }
    end

    it "should pass verify_geocoding for a valid geocoding address" do
      @showing = Showing.new(valid_attributes)
      @showing.save
      expect(@showing.persisted?).to be true
    end

    it "should return false (to cancel db transaction) if either lat or long is unavailable" do
      @showing = Showing.new(invalid_attributes)
      @showing.save
      expect(@showing.persisted?).to be false
    end

  end

end
