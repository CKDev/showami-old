require "rails_helper"

describe Showing do

  context "validations" do

    it "should require a showing date" do
      @showing = FactoryGirl.create(:showing)
      expect(@showing.valid?).to be true
      @showing.update(showing_at: "")
      expect(@showing.valid?).to be false
    end

    it "should not allow a showing time to be in the past" do
      @showing = Showing.new(showing_at: Time.zone.now - 1.minute)
      expect(@showing.valid?).to be false
    end

  end

end
