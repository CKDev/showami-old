module Notification

  class Email

    def self.notify_admins(error, showing_details)
      User.admins.each do |user|
        AdminCCFailureMailer.email(user, error, showing_details).deliver_later
      end
    end

  end

end
