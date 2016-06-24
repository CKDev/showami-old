class AddSentWelcomeSmsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :sent_welcome_sms, :boolean, default: false
  end
end
