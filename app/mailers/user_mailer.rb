class UserMailer < ApplicationMailer

  def invite(email)
    subject = "Showami - Welcome"
    bcc = Rails.env.production? ? "showami2016@gmail.com" : "alex+admin@commercekitchen.com"
    mail(to: email, subject: subject, bcc: bcc)
  end

end
