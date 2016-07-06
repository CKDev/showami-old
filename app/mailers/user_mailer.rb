class UserMailer < ApplicationMailer

  def invite(email)
    subject = "Showami - Welcome"
    mail(to: email, subject: subject)
  end

end
