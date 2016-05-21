class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable

  has_one :profile

  after_create :add_profile

  def add_profile
    build_profile.save(validate: false)
  end

  def admin?
    admin
  end

end
