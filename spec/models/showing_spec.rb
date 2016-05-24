require "rails_helper"

describe Showing do

  context "validations" do

    it "should require a showing date" do
      @showing = FactoryGirl.create(:showing)
      expect(@showing.valid?).to be true
      @showing.update(showing_date: "")
      expect(@showing.valid?).to be false
    end

  end

end
