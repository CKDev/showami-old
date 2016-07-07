class InvitedUser < ActiveRecord::Base
  belongs_to :invited_by, class_name: "User"
  validates :invited_by, presence: true
  validates :email, presence: true
end
