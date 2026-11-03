class Unit < ApplicationRecord
  KINDS = %w[flat shop office].freeze

  belongs_to :property
  has_many :leases, dependent: :restrict_with_error

  scope :occupied, -> { where(status: "occupied") }
  scope :vacant, -> { where(status: "vacant") }

  validates :label, presence: true, uniqueness: { scope: :property_id }
  validates :kind, inclusion: { in: KINDS }

  def name
    "#{property.name}, #{label}"
  end

  def occupied?
    status == "occupied"
  end

  def current_lease
    leases.active.order(start_on: :desc).first
  end

  # Unit status is stored so lists and counts stay cheap; leases keep it in step.
  def refresh_occupancy!
    update!(status: leases.active.exists? ? "occupied" : "vacant")
  end
end
