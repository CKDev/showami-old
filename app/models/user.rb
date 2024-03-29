class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile
  has_many :showings, -> { order("showing_at DESC") }
  has_many :event_logs, -> { order("created_at DESC") }

  after_create :add_profile

  delegate :full_name, to: :profile

  # Note: The in_bounding_box scope will show as a SQL injection risk, but I don't believe it to be
  # since the lat/long values are generated by the google geocoding, and not user entered.
  scope :in_bounding_box, ->(lat, long) { joins(:profile).where("geo_box::box @> point '(#{long},#{lat})'") }
  scope :sellers_agents, -> { joins(:profile).where("profiles.agent_type <> ? ", Profile.agent_types[:buyers_agent]) }
  scope :not_self, ->(id) { where("users.id <> ?", id) }
  scope :not_user, ->(id) { where("users.id <> ?", id) }
  scope :not_blocked, -> { where(blocked: false) }
  scope :not_admin, -> { where(admin: false) }
  scope :admins, -> { where(admin: true) }
  scope :order_by_first_name, -> { joins(:profile).order("profiles.first_name") }

  def send_devise_notification(notification, *args)
    # Sidekiq is picking this job up more quickly than the user can be saved.
    # Wait a few seconds to prevent this error.
    devise_mailer.send(notification, self, *args).deliver_later(wait: 5.seconds)
  end

  def admin?
    admin
  end

  def safe_full_name
    profile.try(:full_name).present? ? full_name : "<not yet entered>"
  end

  def to_s
    "#{full_name} (#{email})"
  end

  def full_details
    "#{full_name} (#{email}, #{primary_phone})"
  end

  def new_user_email_details
    "Name: #{full_name}, Email: #{email}, Cell Phone: #{primary_phone}, Office Phone: #{secondary_phone}, Company Name: #{profile.company}, Agent Id: #{profile.agent_id}, Agent Type: #{profile.agent_type_str}"
  end

  def notify_new_showing(showing)
    ShowingNotificationWorker.perform_async(id, showing.id)
  end

  def notify_new_preferred_showing(showing)
    PreferredShowingNotificationWorker.perform_async(id, showing.id)
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

  def self.user_id_from_email(email)
    return "" unless email.present?
    User.find_by_email!(email).id
  rescue ActiveRecord::RecordNotFound
    ""
  end

  private

  def add_profile
    build_profile.save(validate: false)
  end

end
