class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile
  has_many :showings, -> { order("showing_at DESC") }

  after_create :add_profile
  delegate :greeting, to: :profile

  scope :in_bounding_box, ->(lat, long) { joins(:profile).where("geo_box::box @> point '(#{long},#{lat})'") }

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
    puts "New Showing: #{showing.address.single_line}"
  end

end
