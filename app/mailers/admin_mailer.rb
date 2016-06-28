class AdminMailer < ApplicationMailer

  def email(user, subject, body)
    subject = "Showami Notification" if subject.blank?
    @user = user
    mail(to: @user.email, subject: subject, body: body)
  end

end
