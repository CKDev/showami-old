require "rails_helper"

describe AdminCCFailureMailer do
  describe "email" do

    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { AdminCCFailureMailer.email(user, "error message", "showing details...") }

    it "correctly sets the email params" do
      expect(mail.subject).to eq "Showami Credit Card Charge Failure"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ["no-reply@showami.com"]
      expect(mail.body.encoded).to match("This is a notice that a credit card charge failed to process.")
      expect(mail.body.encoded).to match("Below is information to notify the Buyer's Agent ")
      expect(mail.body.encoded).to match("<strong>The reason for failure: </strong>error message")
      expect(mail.body.encoded).to match("showing details...")
    end

  end
end
