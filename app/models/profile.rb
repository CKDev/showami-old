class Profile < ActiveRecord::Base
  belongs_to :user

  before_validation :strip_phone_numbers
  after_update :send_welcome_text

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone1, presence: true
  validates :phone2, presence: true
  validates :company, presence: true
  validates :agent_id, presence: true
  validates :agent_type, presence: true

  validates_each :phone1, :phone2 do |record, attr, value|
    if value.present?
      record.errors.add(attr, "must have exactly 10 digits") unless value.gsub(/\D/, "").length == 10
    end
  end

  validates :avatar, file_size: { less_than_or_equal_to: 2.5.megabytes }

  mount_uploader :avatar, AvatarUploader

  enum agent_type: [:buyers_agent, :sellers_agent, :both]

  def full_name
    [first_name, last_name].join(" ").strip
  end

  def agent_type_str
    return "Showing" if agent_type == "sellers_agent"
    return "Buyers" if agent_type == "buyers_agent"
    return "Both" if agent_type == "both"
    "<not set>"
  end

  def geo_box_coords
    # [[sw_lat, sw_lon], [ne_lat, ne_lon]]
    # (-104.682, 39.822), (-105.358, 39.427) -> [[" 39.427", " -105.358"], [" 39.822", "-104.682"]]
    return [[0.0, 0.0], [0.0, 0.0]] if geo_box.blank?
    bounds = geo_box.delete("()").split(",")
    [[bounds[3].to_f, bounds[2].to_f], [bounds[1].to_f, bounds[0].to_f]]
  end

  private

  def strip_phone_numbers
    self.phone1 = phone1.gsub(/\D/, "") unless phone1.blank?
    self.phone2 = phone2.gsub(/\D/, "") unless phone2.blank?
  end

  def send_welcome_text
    unless sent_welcome_sms
      update(sent_welcome_sms: true)
      WelcomeNotificationWorker.perform_async(self.user.id)
    end
  end

end
