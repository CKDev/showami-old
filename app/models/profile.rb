class Profile < ActiveRecord::Base
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone1, presence: true
  validates :phone2, presence: true
  validates :company, presence: true
  validates :agent_id, presence: true
  validates :agent_type, presence: true

  enum agent_type: [:buyers_agent, :sellers_agent, :both]

  def greeting
    first_name.present? ? "Hi, #{first_name}!" : "Hi, User!"
  end
end
