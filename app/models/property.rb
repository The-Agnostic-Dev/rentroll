class Property < ApplicationRecord
  has_many :units, -> { order(:label) }, dependent: :destroy
  has_many :leases, through: :units

  validates :name, :address, presence: true

  def occupancy_rate
    return 0 if units.empty?

    (units.occupied.count * 100.0 / units.size).round
  end
end
