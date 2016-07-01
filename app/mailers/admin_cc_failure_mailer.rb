class AdminCCFailureMailer < ApplicationMailer

  def email(user, error, showing_details)
    subject = "Showami Credit Card Charge Failure"
    @user = user
    @error = error
    @showing_details = showing_details
    mail(to: @user.email, subject: subject)
  end

end