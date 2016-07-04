module Notification

  class Email

    def self.notify_admins_cc_failure(error, showing_details)
      Rails.logger.tagged("Admin", "Credit Card Failure") { Rails.logger.error "Sending credit card failure notifications for showing: #{showing_details}" }
      User.admins.each do |user|
        AdminMailer.cc_failure(user, error, showing_details).deliver_later
      end
    end

    def self.notify_admins_new_user(new_user)
      Rails.logger.tagged("Admin", "New User Notification") { Rails.logger.error "Sending notifications for user: #{new_user}" }
      User.admins.each do |user|
        AdminMailer.new_user(user, new_user).deliver_later
      end
    end

  end

end
