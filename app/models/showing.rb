class Showing < ActiveRecord::Base
  belongs_to :user
  has_one :address, as: :addressable, dependent: :destroy
  validates :showing_date, presence: true
  validates_associated :address
  accepts_nested_attributes_for :address
end
