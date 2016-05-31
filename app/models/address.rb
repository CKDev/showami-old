class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true
  validates :line1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true

  geocoded_by :single_line
  after_validation :geocode

  def single_line
    return if line1.empty? || city.empty? || state.empty? || zip.empty?
    adr2 = line2.blank? ? " " : " " + line2 + " "
    line1 + adr2 + city + ", " + state + " " + zip
  end
end
