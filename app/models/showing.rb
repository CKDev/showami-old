class Showing < ActiveRecord::Base
  belongs_to :user
  has_one :address, as: :addressable, dependent: :destroy

  validates :showing_at, presence: true
  validate :showing_at_cannot_be_in_the_past, on: :create
  validates :buyer_name, presence: true
  validates :buyer_phone, presence: true
  validates :buyer_type, presence: true
  validates_associated :address
  accepts_nested_attributes_for :address

  before_save :verify_geocoding

  enum buyer_type: [:individual, :couple, :family]

  def showing_at_cannot_be_in_the_past
    if showing_at.present? && showing_at <= Time.zone.now
      errors.add(:showing_at, "can't be in the past")
    end
  end

  def verify_geocoding
    # Since the geocoding is done after the address is valid, we need to
    # check that the geocoding was successful before allowing a save.  If
    # not, return false which cancels the whole transaction.
    if address.latitude.blank? || address.longitude.blank?
      errors.add(:address, "geocoding was not successful - unable to get coordinates for this showing")
      return false
    end
  end

end
