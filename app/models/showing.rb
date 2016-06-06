class Showing < ActiveRecord::Base
  belongs_to :user
  has_one :address, as: :addressable, dependent: :destroy

  enum buyer_type: [:individual, :couple, :family]
  enum status: [:unconfirmed, :confirmed, :completed, :cancelled]

  validates :showing_at, presence: true
  validates :buyer_name, presence: true
  validates :buyer_phone, presence: true
  validates :buyer_type, presence: true
  validate :showing_at_must_be_in_range, on: :create
  validates_associated :address

  accepts_nested_attributes_for :address

  before_save :verify_geocoding

  def showing_at_must_be_in_range
    if showing_at.present? && showing_at < Time.zone.now + 1.hour
      errors.add(:showing_at, "must be at least one hour from now")
    end

    if showing_at.present? && showing_at > Time.zone.now + 7.days
      errors.add(:showing_at, "cannot be more than seven days from now")
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
