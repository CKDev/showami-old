class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile
  has_many :showings, -> { order("showing_at DESC") }
  has_many :event_logs

  after_create :add_profile

  delegate :full_name, to: :profile

  scope :in_bounding_box, ->(lat, long) { joins(:profile).where("geo_box::box @> point '(#{long},#{lat})'") }
  scope :sellers_agents, -> { joins(:profile).where("profiles.agent_type <> ? ", Profile.agent_types[:buyers_agent]) }
  scope :not_self, ->(id) { where("users.id <> ?", id) }
  scope :not_blocked, -> { where(blocked: false) }
  scope :not_admin, -> { where(admin: false) }
  scope :order_by_first_name, -> { joins(:profile).order("profiles.first_name") }

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

  def safe_full_name
    full_name.present? ? full_name : "<not yet entered>"
  end

  def to_s
    "#{full_name} (#{email})"
  end

  def notify_new_showing(showing)
    log_msg = "Pushing SMS showing notification to background: #{full_name} (#{primary_phone}) -  New Showing: #{showing.address}"
    Log::EventLogger.info(id, showing.id, log_msg, "Showing: #{showing.id}", "Showing Notification SMS")
    ShowingNotificationWorker.perform_async(id, showing.id)
  end

  # For showing agents - need a bank account on file
  def can_accept_showing?
    profile.valid? && valid_bank_token? && !blocked?
  end

  # For buyer's agents - need a credit card on file
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

  def primary_phone
    profile.try(:phone1) || ""
  end

  def secondary_phone
    profile.try(:phone2) || ""
  end

end
