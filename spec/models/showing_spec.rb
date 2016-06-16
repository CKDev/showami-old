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

    it "should not allow a showing time to be less than 1 hour from now" do
      @showing = FactoryGirl.build(:showing)
      @showing.showing_at = Time.zone.now + 59.minutes
      expect(@showing.valid?).to be false

      @showing.showing_at = Time.zone.now + 61.minutes
      expect(@showing.valid?).to be true
    end

    it "should not allow a showing time to be more than 7 days from now" do
      @showing = FactoryGirl.build(:showing)
      @showing.showing_at = Time.zone.now + 6.days + 23.hours + 59.minutes
      expect(@showing.valid?).to be true

      @showing = FactoryGirl.build(:showing)
      @showing.showing_at = Time.zone.now + 7.days + 1.minute
      expect(@showing.valid?).to be false
    end

    it "should require an MLS number" do
      @showing = FactoryGirl.build(:showing, mls: "")
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

    context "#valid_status_change?" do

      it "should initially be in unassigned status" do
        @showing = FactoryGirl.create(:showing)
        expect(@showing.status).to eq "unassigned"
      end

      it "should allow a showing to go from unassigned to unconfirmed" do
        @showing = FactoryGirl.create(:showing)
        @showing.update(status: "unconfirmed")
        expect(@showing.valid?).to be true
      end

      it "should not allow a showing to go from unassigned to confirmed" do
        @showing = FactoryGirl.create(:showing)
        @showing.update(status: "confirmed")
        expect(@showing.valid?).to be false
      end

      it "should not allow a showing to go from unassigned to completed" do
        @showing = FactoryGirl.create(:showing)
        @showing.update(status: "completed")
        expect(@showing.valid?).to be false
      end

      it "should allow a showing to go from unassigned to cancelled" do
        @showing = FactoryGirl.create(:showing)
        @showing.update(status: "cancelled")
        expect(@showing.valid?).to be true
      end

      it "should not allow a showing to go from unconfirmed to unassigned" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "unconfirmed"
        @showing.save(validate: false)
        @showing.update(status: "unassigned")
        expect(@showing.valid?).to be false
      end

      it "should allow a showing to go from unconfirmed to confirmed" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "unconfirmed"
        @showing.save(validate: false)
        @showing.update(status: "confirmed")
        expect(@showing.valid?).to be true
      end

      it "should not allow a showing to go from unconfirmed to completed" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "unconfirmed"
        @showing.save(validate: false)
        @showing.update(status: "completed")
        expect(@showing.valid?).to be false
      end

      it "should allow a showing to go from unconfirmed to cancelled" do
        @showing = FactoryGirl.create(:showing)
        @showing.update(status: "cancelled")
        expect(@showing.valid?).to be true
      end

      it "should not allow a showing to go from confirmed to unconfirmed" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "confirmed"
        @showing.save(validate: false)
        expect(@showing.status).to eq "confirmed"
        @showing.update(status: "unconfirmed")
        expect(@showing.valid?).to be false
      end

      it "should allow a showing to go from confirmed to completed" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "confirmed"
        @showing.save(validate: false)
        expect(@showing.status).to eq "confirmed"
        @showing.update(status: "completed")
        expect(@showing.valid?).to be true
      end

      it "should allow a showing to go from confirmed to cancelled" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "confirmed"
        @showing.save(validate: false)
        expect(@showing.status).to eq "confirmed"
        @showing.update(status: "cancelled")
        expect(@showing.valid?).to be true
      end

      it "should not allow a showing to change status once in completed (except to no_show)" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "completed"
        @showing.save(validate: false)
        expect(@showing.status).to eq "completed"
        Showing.statuses.keys.reject { |k| k == "no_show" || k == "completed" }.each do |status, _v|
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

      it "should allow a showing to go from completed to no_show" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "completed"
        @showing.save(validate: false)
        @showing.update(status: "no_show")
        expect(@showing.valid?).to be true
      end

      it "should only allow a showing to go from completed to no_show for 24 hours" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "completed"
        @showing.showing_at = Time.zone.now - 24.hours - 1.minute
        @showing.save(validate: false)
        @showing.update(status: "no_show")
        expect(@showing.valid?).to be false
      end

      it "should not allow a showing to change status once in cancelled" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "cancelled"
        @showing.save(validate: false)
        expect(@showing.status).to eq "cancelled"
        Showing.statuses.keys.reject { |k| k == "cancelled" }.each do |status, _v|
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

      it "should not allow a showing to go from completed to anything other than no_show" do
        @showing = FactoryGirl.create(:showing)
        Showing.statuses.keys.reject { |k| k == "no_show" || k == "completed" }.each do |status, _v|
          @showing.status = "completed"
          @showing.save(validate: false)
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
        @showing.status = "completed"
        @showing.save(validate: false)
        @showing.update(status: "no_show")
        expect(@showing.valid?).to be true
      end

      it "should not allow a showing to change status once in expired" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "expired"
        @showing.save(validate: false)
        expect(@showing.status).to eq "expired"
        Showing.statuses.keys.reject { |k| k == "expired" }.each do |status, _v|
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

      it "should not allow a showing to change status from no_show" do
        @showing = FactoryGirl.create(:showing)
        Showing.statuses.keys.reject { |k| k == "no_show" }.each do |status, _v|
          @showing.status = "no_show"
          @showing.save(validate: false)
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

    end

    context "#showing_agent_changed?" do

      it "should not allow a showing agent to change once set" do
        @user = FactoryGirl.create(:user_with_valid_profile)
        @user2 = FactoryGirl.create(:user_with_valid_profile)
        @showing = FactoryGirl.create(:showing, showing_agent: @user)
        expect(@showing.update(showing_agent: @user2)).to be false
        expect(@showing.errors.full_messages.first).to eq "Showing agent cannot change the showing agent"
        @showing.reload
        expect(@showing.showing_agent).to eq @user
      end

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

  context "#in_bounding_box" do

    it "should return all showings in the given bounding box" do
      @valid_showing = FactoryGirl.create(:showing)
      @vail_showing = FactoryGirl.create(:showing)
      @vail_address = FactoryGirl.create(:vail_address)
      @vail_showing.update(address: @vail_address)
      expect(Showing.in_bounding_box([[39.500, -105.000], [39.749, -104.800]])).to contain_exactly @valid_showing
    end

    it "should handle invalid input" do
      @valid_showing = FactoryGirl.create(:showing)
      @vail_showing = FactoryGirl.create(:showing)
      @vail_address = FactoryGirl.create(:vail_address)
      @vail_showing.update(address: @vail_address)
      expect(Showing.in_bounding_box(["invalid_data"])).to eq []
    end

  end

  context "#in_future" do

    it "should return all showings where the showing_at is in the future" do
      @past_showing = FactoryGirl.create(:showing)
      @past_showing.showing_at = Time.zone.now - 1.hour
      @past_showing.save(validate: false)
      @future_showing = FactoryGirl.create(:showing, showing_at: Time.zone.now + 2.hours)
      expect(Showing.in_future).to contain_exactly @future_showing
    end

  end

  context "#unassigned" do

    it "should return all showings in unassigned status" do
      @unassigned_showing = FactoryGirl.create(:showing)
      @taken_showing = FactoryGirl.create(:showing, status: "unconfirmed")
      expect(Showing.unassigned).to contain_exactly @unassigned_showing
    end

  end

  context "#available" do

    it "should return all available showings (showings in the bounding box, in the future, and unassigned)" do
      @in_bounding_box = FactoryGirl.create(:showing)
      @vail_showing = FactoryGirl.create(:showing)
      @vail_address = FactoryGirl.create(:vail_address)
      @vail_showing.update(address: @vail_address)
      @past_showing = FactoryGirl.create(:showing)
      @past_showing.showing_at = Time.zone.now - 1.hour
      @past_showing.save(validate: false)
      @future_showing = FactoryGirl.create(:showing, showing_at: Time.zone.now + 2.hours)
      @unassigned_showing = FactoryGirl.create(:showing)
      @taken_showing = FactoryGirl.create(:showing, status: "unconfirmed")
      expect(Showing.available([[39.500, -105.000], [39.749, -104.800]])).to contain_exactly @in_bounding_box, @future_showing, @unassigned_showing
    end

  end

  context ".update_completed" do

    it "should set confirmed showings whos showing date/time has past to completed status" do
      @showing1 = FactoryGirl.create(:showing)
      @showing1.status = "confirmed"
      @showing1.showing_at = Time.zone.now - 1.minute
      @showing1.save(validate: false)

      @showing2 = FactoryGirl.create(:showing)
      @showing2.status = "confirmed"
      @showing2.showing_at = Time.zone.now + 1.minute
      @showing2.save(validate: false)

      @showing3 = FactoryGirl.create(:showing)
      @showing3.status = "confirmed"
      @showing3.showing_at = Time.zone.now + 3.hours
      @showing3.save(validate: false)

      @showing4 = FactoryGirl.create(:showing)
      @showing4.status = "unconfirmed"
      @showing4.showing_at = Time.zone.now - 1.minute
      @showing4.save(validate: false)

      @showing5 = FactoryGirl.create(:showing)
      @showing5.status = "unassigned"
      @showing5.showing_at = Time.zone.now - 1.minute
      @showing5.save(validate: false)

      @showing6 = FactoryGirl.create(:showing)
      @showing6.status = "cancelled"
      @showing6.showing_at = Time.zone.now - 1.minute
      @showing6.save(validate: false)

      Showing.update_completed
      [@showing1, @showing2, @showing3, @showing4, @showing5, @showing6].each(&:reload)
      expect(@showing1.status).to eq "completed"
      expect(@showing2.status).to eq "confirmed"
      expect(@showing3.status).to eq "confirmed"
      expect(@showing4.status).to eq "unconfirmed"
      expect(@showing5.status).to eq "unassigned"
      expect(@showing6.status).to eq "cancelled"

      Timecop.freeze(Time.zone.now + 3.hours + 1.minute) do
        Showing.update_completed
        [@showing1, @showing2, @showing3, @showing4, @showing5, @showing6].each(&:reload)
        expect(@showing1.status).to eq "completed"
        expect(@showing2.status).to eq "completed"
        expect(@showing3.status).to eq "completed"
        expect(@showing4.status).to eq "unconfirmed"
        expect(@showing5.status).to eq "unassigned"
        expect(@showing6.status).to eq "cancelled"
      end

    end

  end

  context ".update_expired" do

    # :unassigned, :unconfirmed, :confirmed, :completed, :cancelled, :expired, :no_show
    it "should set unassigned and unconfirmed showings whos showing date/time has past to expired status" do
      @showing1 = FactoryGirl.create(:showing)
      @showing1.status = "unassigned"
      @showing1.showing_at = Time.zone.now - 1.minute
      @showing1.save(validate: false)

      @showing2 = FactoryGirl.create(:showing)
      @showing2.status = "unassigned"
      @showing2.showing_at = Time.zone.now + 1.minute
      @showing2.save(validate: false)

      @showing3 = FactoryGirl.create(:showing)
      @showing3.status = "unassigned"
      @showing3.showing_at = Time.zone.now + 3.hours
      @showing3.save(validate: false)

      @showing4 = FactoryGirl.create(:showing)
      @showing4.status = "unconfirmed"
      @showing4.showing_at = Time.zone.now - 1.minute
      @showing4.save(validate: false)

      @showing5 = FactoryGirl.create(:showing)
      @showing5.status = "confirmed"
      @showing5.showing_at = Time.zone.now - 1.minute
      @showing5.save(validate: false)

      @showing6 = FactoryGirl.create(:showing)
      @showing6.status = "completed"
      @showing6.showing_at = Time.zone.now - 1.minute
      @showing6.save(validate: false)

      @showing7 = FactoryGirl.create(:showing)
      @showing7.status = "cancelled"
      @showing7.showing_at = Time.zone.now - 1.minute
      @showing7.save(validate: false)

      @showing8 = FactoryGirl.create(:showing)
      @showing8.status = "expired"
      @showing8.showing_at = Time.zone.now - 1.minute
      @showing8.save(validate: false)

      @showing9 = FactoryGirl.create(:showing)
      @showing9.status = "no_show"
      @showing9.showing_at = Time.zone.now - 1.minute
      @showing9.save(validate: false)

      Showing.update_expired
      [@showing1, @showing2, @showing3, @showing4, @showing5, @showing6, @showing7, @showing8, @showing9].each(&:reload)
      expect(@showing1.status).to eq "expired"
      expect(@showing2.status).to eq "unassigned"
      expect(@showing3.status).to eq "unassigned"
      expect(@showing4.status).to eq "expired"
      expect(@showing5.status).to eq "confirmed"
      expect(@showing6.status).to eq "completed"
      expect(@showing7.status).to eq "cancelled"
      expect(@showing8.status).to eq "expired"
      expect(@showing9.status).to eq "no_show"

      Timecop.freeze(Time.zone.now + 3.hours + 1.minute) do
        Showing.update_expired
        [@showing1, @showing2, @showing3, @showing4, @showing5, @showing6, @showing7, @showing8, @showing9].each(&:reload)
        expect(@showing1.status).to eq "expired"
        expect(@showing2.status).to eq "expired"
        expect(@showing3.status).to eq "expired"
        expect(@showing4.status).to eq "expired"
        expect(@showing5.status).to eq "confirmed"
        expect(@showing6.status).to eq "completed"
        expect(@showing7.status).to eq "cancelled"
        expect(@showing8.status).to eq "expired"
        expect(@showing9.status).to eq "no_show"
      end

    end

  end

  context "#no_show_eligible?" do

    it "should return true if it's in completed status and it is still within the 24 hour window" do
      @showing = FactoryGirl.create(:showing)
      @showing.status = "completed"
      @showing.showing_at = Time.zone.now
      @showing.save(validate: false)

      Timecop.freeze(Time.zone.now + 23.hours + 59.minutes) do
        expect(@showing.no_show_eligible?).to be true
      end

      Timecop.freeze(Time.zone.now + 24.hours + 1.minute) do
        expect(@showing.no_show_eligible?).to be false
      end
    end

    it "should return false if it's not in completed status" do
      @showing = FactoryGirl.create(:showing)
      @showing.status = "cancelled"
      @showing.showing_at = Time.zone.now
      @showing.save(validate: false)
      expect(@showing.no_show_eligible?).to be false
    end

  end

end
