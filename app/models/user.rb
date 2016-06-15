class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile
  has_many :showings, -> { order("showing_at DESC") }

  after_create :add_profile

  delegate :full_name, to: :profile

  scope :in_bounding_box, ->(lat, long) { joins(:profile).where("geo_box::box @> point '(#{long},#{lat})'") }
  scope :sellers_agents, -> { joins(:profile).where("profiles.agent_type <> ? ", Profile.agent_types[:buyers_agent]) }
  scope :not_self, ->(id) { where("users.id <> ?", id) }
  scope :not_blocked, -> { where(blocked: false) }

  def send_devise_notification(notification, *args)
    # Sidekiq is picking this job up more quickly than the user can be saved.
    # Wait a few seconds to prevent this error.
    devise_mailer.send(notification, self, *args).deliver_later(wait: 5.seconds)
  end

  def add_profile
    build_profile.save(validate: false)
  end

  def admin?
    admin
  end

  def to_s
    "#{full_name} (#{email})"
  end

  def notify_new_showing(showing)
    log_msg = "Pushing SMS showing notification to background: #{full_name} (#{profile.phone1}) -  New Showing: #{showing.address}"
    Rails.logger.tagged("Showing Notification SMS") { Rails.logger.info log_msg }
    ShowingNotificationWorker.perform_async(id, showing.id)
  end

  # For showing agents - need a bank account on file
  def can_accept_showing?
    profile.valid? && valid_bank_token? && !blocked?
  end

  # For buyer's agents - need a credit card on file
  # TODO: where to use this?  It's not currently used.  Perhaps in the view logic.
  def can_create_showing?
    profile.valid? && valid_credit_card? && !blocked?
  end

  def valid_credit_card?
    profile.cc_token.present?
  end

  def valid_bank_token?
    profile.bank_token.present?
  end

  def blocked?
    blocked
  end

  def buyers_agent?
    profile.agent_type == "buyers_agent"
  end

  def sellers_agent?
    profile.agent_type == "sellers_agent"
  end

  def both_agent_types?
    profile.agent_type == "both"
  end

end
