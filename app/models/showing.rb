require "geocoder/sql"
require "geocoder/stores/base"

class Showing < ActiveRecord::Base

  has_paper_trail # Auditing

  belongs_to :user
  belongs_to :showing_agent, class_name: "User"
  has_one :address, as: :addressable, dependent: :destroy

  enum buyer_type: [:individual, :couple, :family]
  enum status: [:unassigned, :unconfirmed, :confirmed, :completed, :cancelled, :expired, :no_show]

  validates :showing_at, presence: true
  validates :mls, presence: true
  validates :buyer_name, presence: true
  validates :buyer_phone, presence: true
  validates :buyer_type, presence: true
  validate :showing_at_must_be_in_range, on: :create
  validate :valid_status_change?
  validate :showing_agent_changed?
  validates_associated :address

  validates_each :buyer_phone do |record, attr, value|
    if value.present?
      record.errors.add(attr, "must have exactly 10 digits") unless value.gsub(/\D/, "").length == 10
    end
  end

  accepts_nested_attributes_for :address

  before_save :verify_geocoding
  after_save :log_change

  default_scope { order("showing_at DESC") }
  scope :in_future, -> { where("showing_at > ?", Time.zone.now) }
  scope :unassigned, -> { where("status = ?", statuses[:unassigned]) }
  scope :completed, -> { where("status = ? AND showing_at < ?", statuses[:confirmed], Time.zone.now) }
  scope :expired, -> { where(status: [statuses[:unassigned], statuses[:unconfirmed]]).where("showing_at < ?", Time.zone.now) }

  # Note: This method was copied right from the Geocoder source (within_bounding_box)
  # so that I could apply it to the Showing model instead of having to run it on
  # the Address model, which caused all kinds of complications.
  scope :in_bounding_box, lambda { |bounds|
    sw_lat, sw_lng, ne_lat, ne_lng = bounds.flatten if bounds
    if sw_lat && sw_lng && ne_lat && ne_lng
      joins(:address).where(
        Geocoder::Sql.within_bounding_box(sw_lat, sw_lng, ne_lat, ne_lng, "addresses.latitude", "addresses.longitude")
      )
    else
      joins(:address).where("false")
    end
  }

  def showing_at_must_be_in_range
    if showing_at.present? && showing_at < Time.zone.now + 1.hour
      errors.add(:showing_at, "must be at least one hour from now")
    end

    if showing_at.present? && showing_at > Time.zone.now + 7.days
      errors.add(:showing_at, "cannot be more than seven days from now")
    end
  end

  def valid_status_change?
    if status_changed?
      if status_was == "unassigned"
        check_unassigned_state_change
      elsif status_was == "unconfirmed"
        check_unconfirmed_state_change
      elsif status_was == "confirmed"
        check_confirmed_state_change
      elsif status_was == "completed"
        check_completed_state_change
      elsif status_was == "cancelled"
        check_cancelled_state_change
      elsif status_was == "expired"
        check_expired_state_change
      elsif status_was == "no_show"
        check_no_show_state_change
      end
    end
  end

  def showing_agent_changed?
    if showing_agent_id_changed? && showing_agent_id_was.present?
      errors.add(:showing_agent, "cannot change the showing agent")
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

  def log_change
    unless Rails.env.test?
      version = self.versions.last
      modified_by_id = version.whodunnit
      modified_by = modified_by_id.present? ? User.find(modified_by_id).to_s : "<System>"
      Rails.logger.tagged("Showing Update", id) { Rails.logger.info "#{self}, Modified By: #{modified_by}" }
    end
  end

  def self.available(geo_box_coords)
    Showing.in_bounding_box(geo_box_coords).in_future.unassigned
  end

  # NOTE: called from a cron job, keep name in sync with schedule.rb.
  def self.update_completed
    Rails.logger.tagged("Cron - Showing.update_completed") { Rails.logger.info "Checking for completed showings..." }
    # I'm running this in a loop (vs update_all) to make sure callbacks fire.  It runs every minute so performance shouldn't be an issue.
    Showing.completed.each do |s|
      s.update(status: statuses[:completed])
      Rails.logger.tagged("Cron - Showing.update_completed") { Rails.logger.info "Marked #{s} as completed." }
    end
  end

  # NOTE: called from a cron job, keep name in sync with schedule.rb.
  def self.update_expired
    Rails.logger.tagged("Cron - Showing.update_expired") { Rails.logger.info "Checking for expired showings..." }
    # I'm running this in a loop (vs update_all) to make sure callbacks fire.  It runs every minute so performance shouldn't be an issue.
    Showing.expired.each do |s|
      s.update(status: statuses[:expired])
      Rails.logger.tagged("Cron - Showing.update_expired") { Rails.logger.info "Marked #{s} as expired." }
    end
  end

  def no_show_eligible?
    return false if status != "completed"
    return false if Time.zone.now > showing_at + 24.hours
    true
  end

  def to_s
    "Showing #{id}: Buyer's Agent: #{user}, Address: #{address}, MLS: #{mls}, Showing Status: #{status}, Updated At: #{updated_at}"
  end

  private

  def check_unassigned_state_change
    errors.add(:status, "cannot change from unassigned to confirmed, it must be unconfirmed first") if status == "confirmed"
    errors.add(:status, "cannot change from unassigned to completed, it must be unconfirmed first") if status == "completed"
  end

  def check_unconfirmed_state_change
    errors.add(:status, "cannot change from unconfirmed to unassigned") if status == "unassigned"
    errors.add(:status, "cannot change from unconfirmed to completed, it must be confirmed first") if status == "completed"
  end

  def check_confirmed_state_change
    errors.add(:status, "cannot change from confirmed to unconfirmed") if status == "unconfirmed"
  end

  def check_completed_state_change
    if status == "no_show"
      if Time.zone.now > showing_at + 24.hours
        errors.add(:status, "can only set as a 'no show' for 24 hours after the showing time")
      end
    else
      errors.add(:status, "cannot change status, once completed")
    end
  end

  def check_cancelled_state_change
    errors.add(:status, "cannot change status, once cancelled")
  end

  def check_expired_state_change
    errors.add(:status, "cannot change status, once expired")
  end

  def check_no_show_state_change
    errors.add(:status, "cannot change status, once in no-show")
  end

end
