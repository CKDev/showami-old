class Profile < ActiveRecord::Base
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone1, presence: true
  validates :phone2, presence: true
  validates :company, presence: true
  validates :agent_id, presence: true
  validates :agent_type, presence: true

  has_attached_file :avatar, styles: { small: "200x200#" }, default_url: ActionController::Base.helpers.asset_path("/assets/:style/avatar.png")
  validates_attachment :avatar, content_type: { content_type: /\Aimage\/.*\Z/ }, size: { in: 0..1024.kilobytes }

  enum agent_type: [:buyers_agent, :sellers_agent, :both]

  def greeting
    first_name.present? ? "Hi, #{first_name}!" : "Hi, User!"
  end
end
