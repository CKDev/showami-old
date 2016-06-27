class AddSentUnassignedNotificationSmsToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :sent_unassigned_notification_sms, :boolean, default: false
  end
end
