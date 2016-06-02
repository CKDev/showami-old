class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile
  has_many :showings, -> { order("showing_at DESC") }

  after_create :add_profile

  delegate :greeting, to: :profile
  delegate :full_name, to: :profile

  scope :in_bounding_box, ->(lat, long) { joins(:profile).where("geo_box::box @> point '(#{long},#{lat})'") }
  scope :sellers_agents, -> { joins(:profile).where("profiles.agent_type <> ? ", Profile.agent_types[:buyers_agent]) }
  scope :not_self, ->(id) { where("users.id <> ?", id) }

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

  def notify_new_showing(showing)
    to = profile.phone1
    body = "There is a new showing available at: #{showing.address.single_line}"
    log_msg = "Attempting SMS showing notification to #{full_name} (#{profile.phone1}) -  New Showing: #{showing.address.single_line}"
    Rails.logger.tagged("SMS (Twilio)") { Rails.logger.info log_msg }
    Notification::SMS.new(to, body).send
  end

end
