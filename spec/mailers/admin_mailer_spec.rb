require "rails_helper"

describe AdminMailer do

  describe "cc_failure" do

    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { AdminMailer.cc_failure(user, "error message", "showing details...") }

    it "correctly sets the email params" do
      expect(mail.subject).to eq "Showami Credit Card Charge Failure"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ["no-reply@showami.com"]
      expect(mail.body.encoded).to have_content("This is a notice that a credit card charge failed to process.")
      expect(mail.body.encoded).to have_content("Below is information to notify the Buyer's Agent ")
      expect(mail.body.encoded).to match("<strong>The reason for failure: </strong>error message")
      expect(mail.body.encoded).to have_content("showing details...")
    end
  end

  describe "new_user" do

    let(:admin) { FactoryGirl.create(:user, admin: true) }
    let(:new_user) { FactoryGirl.create(:user) }
    let(:mail) { AdminMailer.new_user(admin, new_user) }

    it "correctly sets the email params" do
      expect(mail.subject).to eq "Showami - New User Signup"
      expect(mail.to).to eq [admin.email]
      expect(mail.from).to eq ["no-reply@showami.com"]
      expect(mail.body.encoded).to have_content("A new user has signed up:")
      expect(mail.body.encoded).to have_content(new_user.full_details)
    end
  end

end
