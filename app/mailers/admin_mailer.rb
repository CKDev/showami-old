class AdminMailer < ApplicationMailer

  def cc_failure(user, error, showing_details)
    subject = "Showami Credit Card Charge Failure"
    @user = user
    @error = error
    @showing_details = showing_details
    mail(to: @user.email, subject: subject)
  end

  def new_user(admin, new_user)
    subject = "Showami - New User Signup"
    @new_user = new_user
    mail(to: admin.email, subject: subject)
  end

end
