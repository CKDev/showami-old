class AddSentConfirmationReminderSmsToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :sent_confirmation_reminder_sms, :boolean, default: false
  end
end
