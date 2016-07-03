module Notification

  class Email

    def self.notify_admins_cc_failure(error, showing_details)
      User.admins.each do |user|
        AdminMailer.cc_failure(user, error, showing_details).deliver_later
      end
    end

  end

end
