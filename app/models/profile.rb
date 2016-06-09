class Profile < ActiveRecord::Base
  belongs_to :user

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone1, presence: true
  validates :phone2, presence: true
  validates :company, presence: true
  validates :agent_id, presence: true
  validates :agent_type, presence: true

  before_validation :strip_phone_numbers

  validates_each :phone1, :phone2 do |record, attr, value|
    if value.present?
      record.errors.add(attr, "must have exactly 10 digits") unless value.gsub(/\D/, "").length == 10
    end
  end

  has_attached_file :avatar, styles: { small: "200x200#", mini: "75x75#" }, default_url: ActionController::Base.helpers.asset_path("/assets/:style/avatar.png")
  validates_attachment :avatar, content_type: { content_type: /\Aimage\/.*\Z/ }, size: { in: 0..1024.kilobytes }

  enum agent_type: [:buyers_agent, :sellers_agent, :both]

  def greeting
    first_name.present? ? "Hi, #{first_name}!" : "Hi, User!"
  end

  def full_name
    [first_name, last_name].join(" ").strip
  end

  def strip_phone_numbers
    self.phone1 = phone1.gsub(/\D/, "") unless phone1.blank?
    self.phone2 = phone2.gsub(/\D/, "") unless phone2.blank?
  end

  def geo_box_coords
    # [[sw_lat, sw_lon], [ne_lat, ne_lon]]
    # (-104.682, 39.822), (-105.358, 39.427) -> [[" 39.427", " -105.358"], [" 39.822", "-104.682"]]
    return [[0.0, 0.0], [0.0, 0.0]] if geo_box.blank?
    bounds = geo_box.delete("()").split(",")
    [[bounds[3].to_f, bounds[2].to_f], [bounds[1].to_f, bounds[0].to_f]]
  end

end
