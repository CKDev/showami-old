module Mixins
  module ShowingCron
    extend ActiveSupport::Concern

    # NOTE: All of these called from a cron job, keep method names in sync with schedule.rb.
    module ClassMethods

      def update_completed
        Rails.logger.tagged("Cron", "Showing.update_completed") { Rails.logger.info "Checking for completed showings..." }
        Showing.completed.each do |showing|
          showing.update(status: statuses[:completed])
          Log::EventLogger.info(nil, showing.id, "Marked as completed.", "Cron", "Showing.update_completed", "Showing: #{showing.id}")
        end
      end

      def update_expired
        Rails.logger.tagged("Cron", "Showing.update_expired") { Rails.logger.info "Checking for expired showings..." }
        Showing.expired.each do |showing|
          showing.update(status: statuses[:expired])
          Log::EventLogger.info(nil, showing.id, "Marked as expired.", "Cron", "Showing.update_expired", "Showing: #{showing.id}")
        end
      end

      def start_payment_charges
        Rails.logger.tagged("Cron", "Showing.start_payment_charges") { Rails.logger.info "Checking for showings in need of making payments..." }
        Showing.ready_for_payment.each do |showing|
          showing.update(status: statuses[:processing_payment])
          Log::EventLogger.info(nil, showing.id, "Created charge payment job.", "Cron", "Showing.start_payment_charges", "Showing: #{showing.id}")
          ChargeWorker.perform_async(showing.id)
        end
      end

      def start_payment_transfers
        Rails.logger.tagged("Cron", "Showing.start_payment_transfers") { Rails.logger.info "Checking for showings in need of making transfers..." }
        Showing.ready_for_transfer.each do |showing|
          showing.update(status: statuses[:processing_payment]) # Should already be in processing_payment.
          Log::EventLogger.info(nil, showing.id, "Created transfer payment job.", "Cron", "Showing.start_payment_transfers", "Showing: #{showing.id}")
          TransferWorker.perform_async(showing.id)
        end
      end

      def update_paid
        Rails.logger.tagged("Cron", "Showing.update_paid") { Rails.logger.info "Checking for showings that can be safely marked as paid" }
        Showing.ready_for_paid.each do |showing|
          showing.update(status: statuses[:paid])
          showing.update(payment_status: payment_statuses[:paying_sellers_agent_success])
          Log::EventLogger.info(nil, showing.id, "Marked as paid.", "Cron", "Showing.update_paid", "Showing: #{showing.id}")
        end
      end

      def send_confirmation_reminders
        Rails.logger.tagged("Cron", "Showing.send_confirmation_reminders") { Rails.logger.info "Checking for showings that are within 30 minutes and have not been confirmed." }
        Showing.need_confirmation_reminder.each do |showing|
          showing.update(sent_confirmation_reminder_sms: true)
          ConfirmationReminderWorker.perform_async(showing.id)
        end
      end

      def send_unassigned_notifications
        Rails.logger.tagged("Cron", "Showing.send_unassigned_notification") { Rails.logger.info "Checking for showings that are within 30 minutes and have not been assigned." }
        Showing.need_unassigned_notification.each do |showing|
          showing.update(sent_unassigned_notification_sms: true)
          UnassignedNotificationWorker.perform_async(showing.id)
        end
      end
    end

  end
end
