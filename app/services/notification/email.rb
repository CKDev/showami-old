module Notification

  class Email

    def self.notify_admins(subject, body)
      User.admins.each do |user|
        AdminMailer.email(user, subject, body).deliver_later
      end
    end

  end

end
