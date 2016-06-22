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

    it "requires phone to be a ten digit number" do
      @showing = FactoryGirl.build(:showing, buyer_phone: "")

      @showing.update(buyer_phone: "7208881234")
      expect(@showing.valid?).to be true

      @showing.update(buyer_phone: "(720) 123 - 1234")
      expect(@showing.valid?).to be true
      expect(@showing.buyer_phone).to eq "7201231234"

      @showing.update(buyer_phone: "(720)123-1234")
      expect(@showing.valid?).to be true
      expect(@showing.buyer_phone).to eq "7201231234"

      @showing.update(buyer_phone: "720.123.1234")
      expect(@showing.valid?).to be true
      expect(@showing.buyer_phone).to eq "7201231234"

      @showing.update(buyer_phone: "123456789")
      expect(@showing.valid?).to be false

      @showing.update(buyer_phone: "12345678901")
      expect(@showing.valid?).to be false

      @showing.update(buyer_phone: "(720)123-1234 x 1234")
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

      it "should allow a completed showing to only change to no_show or processing_payment" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "completed"
        @showing.save(validate: false)
        expect(@showing.status).to eq "completed"
        Showing.statuses.keys.reject { |k| k == "completed" || k == "no_show" || k == "processing_payment" }.each do |status, _v|
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

      it "should allow a showing to go from completed to processing_payment" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "completed"
        @showing.showing_at = Time.zone.now - 24.hours - 1.minute
        @showing.save(validate: false)
        @showing.update(status: "processing_payment")
        expect(@showing.valid?).to be true
      end

      it "should only allow a showing to go from completed to processing_payment after 24 hours" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "completed"
        @showing.showing_at = Time.zone.now - 23.hours - 59.minutes
        @showing.save(validate: false)
        @showing.update(status: "processing_payment")
        expect(@showing.valid?).to be false
      end

      it "should not allow a showing to go from processing_payment to anthing other than paid" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "processing_payment"
        @showing.save(validate: false)
        Showing.statuses.keys.reject { |k| k == "processing_payment" || k == "paid" }.each do |status, _v|
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

      it "should allow a showing to go from processing_payment to paid" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "processing_payment"
        @showing.save(validate: false)
        @showing.update(status: "paid")
        expect(@showing.valid?).to be true
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

      it "should allow a showing to go from completed to no_show" do
        @showing = FactoryGirl.create(:showing)
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

      it "should not allow a showing to change status from paid" do
        @showing = FactoryGirl.create(:showing)
        Showing.statuses.keys.reject { |k| k == "paid" }.each do |status, _v|
          @showing.status = "paid"
          @showing.save(validate: false)
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

      it "should not allow a showing to go from cancelled_with_payment to anthing other than processing_payment" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "cancelled_with_payment"
        @showing.save(validate: false)
        Showing.statuses.keys.reject { |k| k == "cancelled_with_payment" || k == "processing_payment" }.each do |status, _v|
          @showing.update(status: status)
          expect(@showing.valid?).to be false
        end
      end

      it "should allow a showing to go from cancelled_with_payment to processing_payment" do
        @showing = FactoryGirl.create(:showing)
        @showing.status = "cancelled_with_payment"
        @showing.save(validate: false)
        @showing.update(status: "processing_payment")
        expect(@showing.valid?).to be true
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

  context "query scopes" do

    context ".in_bounding_box" do

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

    context ".in_future" do

      it "should return all showings where the showing_at is in the future" do
        @past_showing = FactoryGirl.create(:showing)
        @past_showing.showing_at = Time.zone.now - 1.hour
        @past_showing.save(validate: false)
        @future_showing = FactoryGirl.create(:showing, showing_at: Time.zone.now + 2.hours)
        expect(Showing.in_future).to contain_exactly @future_showing
      end

    end

    context ".unassigned" do

      it "should return all showings in unassigned status" do
        @unassigned_showing = FactoryGirl.create(:showing)
        @taken_showing = FactoryGirl.create(:showing, status: "unconfirmed")
        expect(Showing.unassigned).to contain_exactly @unassigned_showing
      end

    end

    context ".available" do

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

    context ".ready_for_payment" do

      it "should return all showings in completed status that are 24 hours past the showing time" do
        @showing1 = FactoryGirl.build(:showing, status: "completed", showing_at: Time.zone.now - 24.hours - 1.minute)
        @showing2 = FactoryGirl.build(:showing, status: "completed", showing_at: Time.zone.now - 23.hours - 59.minutes)
        @showing3 = FactoryGirl.build(:showing, status: "paid", showing_at: Time.zone.now - 24.hours - 1.minute)
        @showing4 = FactoryGirl.build(:showing, status: "expired", showing_at: Time.zone.now - 24.hours - 1.minute)
        [@showing1, @showing2, @showing3, @showing4].each { |s| s.save(validate: false) }
        expect(Showing.ready_for_payment).to contain_exactly @showing1
        Timecop.freeze(Time.zone.now + 3.minutes) do
          expect(Showing.ready_for_payment).to contain_exactly @showing1, @showing2
        end
      end

      it "should return all showings in cancelled_with_payment status, whos showing time has passed" do
        @showing1 = FactoryGirl.build(:showing, status: "cancelled_with_payment", showing_at: Time.zone.now - 1.minute)
        @showing2 = FactoryGirl.build(:showing, status: "cancelled_with_payment", showing_at: Time.zone.now + 1.minute)
        @showing3 = FactoryGirl.build(:showing, status: "completed", showing_at: Time.zone.now - 23.hours - 59.minutes)
        [@showing1, @showing2, @showing3].each { |s| s.save(validate: false) }
        expect(Showing.ready_for_payment).to contain_exactly @showing1
        Timecop.freeze(Time.zone.now + 3.minutes) do
          expect(Showing.ready_for_payment).to contain_exactly @showing1, @showing2, @showing3
        end
      end

    end

    context ".ready_for_transfer" do

      it "should return all showings in processing_payment that have successfully charged the buyer's agent" do
        @showing1 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent_success")
        @showing2 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent_failure")
        @showing3 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent")
        @showing4 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "paying_sellers_agent")
        @showing5 = FactoryGirl.build(:showing, status: "paid", payment_status: "charging_buyers_agent_success")
        [@showing1, @showing2, @showing3, @showing4, @showing5].each { |s| s.save(validate: false) }
        expect(Showing.ready_for_transfer).to contain_exactly @showing1
      end

    end

    context ".ready_for_paid" do

      it "should return all showings in status processing_payment and have been in payment_status: paying_sellers_agent_started for 5 days" do
        @showing1 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "paying_sellers_agent_started", showing_at: Time.zone.now - 6.days - 1.minute)
        @showing2 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "paying_sellers_agent_started", showing_at: Time.zone.now - 5.days - 23.hours)
        @showing3 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent_success", showing_at: Time.zone.now - 6.days - 1.minute)
        @showing4 = FactoryGirl.build(:showing, status: "paid", payment_status: "paying_sellers_agent_started", showing_at: Time.zone.now - 6.days - 1.minute)
        [@showing1, @showing2, @showing3, @showing4].each { |s| s.save(validate: false) }
        expect(Showing.ready_for_paid).to contain_exactly @showing1
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

  context "cron job status changes" do

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

    context ".start_payment_charges" do

      it "should kick off a background job to charge credit card when a showing has been completed for 24 hours" do
        @showing1 = FactoryGirl.build(:showing, status: "completed", showing_at: Time.zone.now - 24.hours - 1.minute)
        @showing1.save(validate: false)
        @showing2 = FactoryGirl.build(:showing, status: "completed", showing_at: Time.zone.now - 23.hours - 59.minutes)
        @showing2.save(validate: false)

        ChargeWorker.expects(:perform_async).once.with(@showing1.id)
        Showing.start_payment_charges

        [@showing1, @showing2].each(&:reload)
        expect(@showing1.status).to eq "processing_payment"
        expect(@showing2.status).to eq "completed"

        Timecop.freeze(Time.zone.now + 3.minutes) do
          ChargeWorker.expects(:perform_async).once.with(@showing2.id)
          Showing.start_payment_charges

          [@showing1, @showing2].each(&:reload)
          expect(@showing1.status).to eq "processing_payment"
          expect(@showing2.status).to eq "processing_payment"
        end

      end

    end

    context ".start_payment_transfers" do

      it "should kick off a background job to transfer bank payment after a successful credit card charge" do
        @showing1 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent_success")
        @showing2 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent_failure")
        @showing3 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent")
        @showing4 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "paying_sellers_agent")
        @showing5 = FactoryGirl.build(:showing, status: "paid", payment_status: "charging_buyers_agent_success")
        [@showing1, @showing2, @showing3, @showing4, @showing5].each { |s| s.save(validate: false) }

        TransferWorker.expects(:perform_async).once.with(@showing1.id)
        Showing.start_payment_transfers
        @showing1.reload
        expect(@showing1.status).to eq "processing_payment"
      end

    end

    context ".update_paid" do

      it "should mark all ready_for_paid showings as paid" do
        @showing1 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "paying_sellers_agent_started", showing_at: Time.zone.now - 6.days - 1.minute)
        @showing2 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "paying_sellers_agent_started", showing_at: Time.zone.now - 5.days - 23.hours)
        @showing3 = FactoryGirl.build(:showing, status: "processing_payment", payment_status: "charging_buyers_agent_success", showing_at: Time.zone.now - 6.days - 1.minute)
        @showing4 = FactoryGirl.build(:showing, status: "paid", payment_status: "paying_sellers_agent_started", showing_at: Time.zone.now - 6.days - 1.minute)
        [@showing1, @showing2, @showing3, @showing4].each { |s| s.save(validate: false) }

        Showing.update_paid
        @showing1.reload
        expect(@showing1.status).to eq "paid"
        expect(@showing1.payment_status).to eq "paying_sellers_agent_success"
      end

    end

  end

  context "#after_deadline?" do

    it "should return true if the showing_at is less than 4 hours away" do
      @showing = FactoryGirl.create(:showing, showing_at: Time.zone.now + 3.hours + 59.minutes)
      expect(@showing.after_deadline?).to be true
    end

    it "should return false if the showing_at is more than 4 hours away" do
      @showing = FactoryGirl.create(:showing, showing_at: Time.zone.now + 4.hours + 1.second)
      expect(@showing.after_deadline?).to be false
    end

  end

  context "#showing_agent_visible?" do

    it "should show the showing agent, only in unconfirmed confirmed completed and no_show statuses" do
      showing = Showing.new
      Showing.statuses.each do |status, _index|
        showing.status = status
        if %w(unconfirmed confirmed completed no_show).include? status
          expect(showing.showing_agent_visible?).to be true
        else
          expect(showing.showing_agent_visible?).to be false
        end
      end
    end

  end

  context "helper methods" do

    before :each do
      @buyers_agent = FactoryGirl.create(:user_with_valid_profile)
      @buyers_agent.profile.update(phone1: "1231231234")
      @showing_agent = FactoryGirl.create(:user_with_valid_profile)
      @showing_agent.profile.update(phone1: "9879879879")
      @showing = FactoryGirl.create(:showing, user: @buyers_agent, showing_agent: @showing_agent)
    end

    it "showing_agent_phone should return the showing agent's phone1" do
      expect(@showing.showing_agent_phone).to eq "9879879879"
    end

    it "buyers_agent_phone should return the buyers agent's phone1" do
      expect(@showing.buyers_agent_phone).to eq "1231231234"
    end

  end

end
