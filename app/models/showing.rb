class Showing < ActiveRecord::Base
  belongs_to :user
  has_one :address, as: :addressable, dependent: :destroy

  validates :showing_at, presence: true
  validate :showing_at_cannot_be_in_the_past
  validates_associated :address
  accepts_nested_attributes_for :address

  enum buyer_type: [:individual, :couple, :family]

  def showing_at_cannot_be_in_the_past
    if showing_at.present? && showing_at <= Time.zone.now
      errors.add(:showing_at, "can't be in the past")
    end
  end

end
