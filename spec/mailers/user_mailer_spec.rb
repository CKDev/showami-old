require "rails_helper"

describe UserMailer do

  describe "invite" do

    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.invite("something@example.com") }

    it "correctly sets the email params" do
      expect(mail.subject).to eq "Showami - Welcome"
      expect(mail.to).to eq ["something@example.com"]
      expect(mail.from).to eq ["no-reply@showami.com"]
      expect(mail.body.encoded).to have_content("Hello, (message about why you are getting this email)")
    end
  end

end
