require "geocoder/sql"
require "geocoder/stores/base"

class Showing < ActiveRecord::Base

  include Mixins::ShowingCron

  has_paper_trail # Auditing

  belongs_to :user
  belongs_to :showing_agent, class_name: "User"
  has_one :address, as: :addressable, dependent: :destroy
  has_many :event_logs

  enum buyer_type: [:individual, :couple, :family]
  enum status: [:unassigned, :unconfirmed, :confirmed, :completed,
    :cancelled, :expired, :no_show, :processing_payment, :paid, :cancelled_with_payment]
  enum payment_status: [:unpaid,
    :charging_buyers_agent, :charging_buyers_agent_success, :charging_buyers_agent_failure,
    :paying_sellers_agent, :paying_sellers_agent_started, :paying_sellers_agent_success, :paying_sellers_agent_failure]

  before_validation :strip_phone_numbers

  validates :showing_at, presence: true
  validates :mls, presence: true
  validates :buyer_name, presence: true
  validates :buyer_phone, presence: true
  validates :buyer_type, presence: true
  validates :notes, length: { maximum: 400 }
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
  scope :need_confirmation_reminder, -> { where("sent_confirmation_reminder_sms = ? AND showing_at < ? AND status = ?", false, Time.zone.now + 30.minutes, statuses[:unconfirmed]) }
  scope :need_unassigned_notification, -> { where("sent_unassigned_notification_sms = ? AND showing_at < ? AND status = ?", false, Time.zone.now + 30.minutes, statuses[:unassigned]) }
  scope :ready_for_payment, lambda {
    where("(status = ? AND showing_at < ?) OR (status = ? AND showing_at < ?)",
      statuses[:completed], Time.zone.now - 24.hours,
      statuses[:cancelled_with_payment], Time.zone.now)
  }
  scope :expired, lambda {
    where("(status = ? AND showing_at < ?) OR (status = ? AND showing_at < ?)",
      statuses[:unassigned], Time.zone.now,
      statuses[:unconfirmed], Time.zone.now - 6.hours)
  }
  scope :ready_for_transfer, -> { where("status = ? AND payment_status = ?", statuses[:processing_payment], payment_statuses[:charging_buyers_agent_success]) }

  scope :ready_for_paid, lambda {
    # We can only safely assume that a transfer is complete after 5 days of not receiving a transfer.failed message.
    # So, 24 hours after showing time + 5 days of in process.
    where("status = ? AND payment_status = ? AND showing_at < ?",
      statuses[:processing_payment],
      payment_statuses[:paying_sellers_agent_started],
      Time.zone.now - 6.days)
  }

  scope :in_bounding_box, lambda { |bounds|
    # Note: This method was copied right from the Geocoder source (within_bounding_box)
    # so that I could apply it to the Showing model instead of having to run it on
    # the Address model, which caused all kinds of complications.
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
      elsif status_was == "processing_payment"
        check_processing_payment_state_change
      elsif status_was == "paid"
        check_paid_state_change
      elsif status_was == "cancelled_with_payment"
        check_cancelled_with_payment_status
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
      Log::EventLogger.info(nil, id, "#{self}, Modified By: #{modified_by}", "Showing: #{id}", "Showing Update")
    end
  end

  def self.available(geo_box_coords)
    Showing.in_bounding_box(geo_box_coords).in_future.unassigned
  end

  def no_show_eligible?
    return false if status != "completed"
    return false if Time.zone.now > showing_at + 24.hours
    true
  end

  def after_deadline?
    showing_at < Time.zone.now + 4.hours
  end

  def cancel_causes_payment?
    after_deadline? && status.in?(%w(unconfirmed confirmed))
  end

  def showing_agent_visible?(current_user)
    (status.in? %w(unconfirmed confirmed completed no_show)) && (current_user == self.user || current_user == showing_agent)
  end

  def buyer_info_visible?(current_user)
    current_user == self.user || (current_user == showing_agent && status != "unassigned")
  end

  def notes_visible?(current_user)
    current_user == self.user || (current_user == showing_agent && notes.present? && status != "unassigned")
  end

  def showing_agent_phone
    showing_agent.primary_phone
  end

  def buyers_agent_phone
    user.primary_phone
  end

  def who_cancelled
    changeset = versions.last.changeset
    if changeset.keys.include?("status") && changeset[:status].second.in?(["cancelled", "cancelled_with_payment"])
      user = User.find(versions.last.whodunnit)
      return "Cancelled by: #{user.full_name} on #{versions.last.created_at.strftime(Constants.datetime_format)}"
    end
    ""
  rescue
    ""
  end

  def to_s
    "Showing #{id}: Buyer's Agent: #{user}, Address: #{address}, MLS: #{mls}, Showing Status: #{status}, Payment Status: #{payment_status}, Updated At: #{updated_at}"
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
        errors.add(:status, "can only set as a 'no-show' for 24 hours after the showing time")
      end
    elsif status == "processing_payment"
      if Time.zone.now < showing_at + 24.hours
        errors.add(:status, "can only start the payment process 24 hours after the showing time")
      end
    else
      errors.add(:status, "can only change from completed to payment-processing or no-show")
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

  def check_processing_payment_state_change
    errors.add(:status, "can only change from processing_payment to paid") unless status == "paid"
  end

  def check_paid_state_change
    errors.add(:status, "cannot change status, once in paid")
  end

  def check_cancelled_with_payment_status
    errors.add(:status, "can only change from cancelled_with_payment to processing_payment") unless status == "processing_payment"
  end

  def strip_phone_numbers
    self.buyer_phone = buyer_phone.gsub(/\D/, "") unless buyer_phone.blank?
  end

end
