class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile
  has_many :showings, -> { order(:showing_at) }
  after_create :add_profile

  delegate :greeting, to: :profile

  def add_profile
    build_profile.save(validate: false)
  end

  def admin?
    admin
  end

end
