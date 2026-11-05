class Lease < ApplicationRecord
  FREQUENCIES = %w[monthly annual].freeze

  # Rent is only counted as late once this many days have passed after the due date.
  GRACE_DAYS = 5

  belongs_to :unit
  belongs_to :tenant
  has_many :payments, -> { order(:paid_on, :id) }, dependent: :restrict_with_error

  scope :active, -> { where(status: "active") }
  scope :running, ->(today: Date.current) { active.where(start_on: ..today, end_on: today..) }

  validates :start_on, :end_on, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }
  validates :rent_amount, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validate :ends_after_start
  validate :unit_is_free, on: :create

  after_commit :sync_unit_occupancy, on: %i[create destroy]
  after_commit -> { DashboardSummary.expire }, on: %i[create update destroy]

  # Active leases running out within the next `days` days, for renewal follow-up.
  def self.up_for_renewal(days, today: Date.current)
    active.where(end_on: today..(today + days)).order(end_on: :asc)
  end

  def active?
    status == "active"
  end

  def monthly?
    frequency == "monthly"
  end

  # Last day rent is charged for: the move-out date if the lease ended early.
  def charged_until
    [ ended_on, end_on ].compact.min
  end

  def end_early!(on:)
    update!(status: "ended", ended_on: on)
  end

  def ledger
    @ledger ||= LeaseLedger.new(self)
  end

  def days_to_expiry(today = Date.current)
    (end_on - today).to_i
  end

  def describe_rent
    "#{ActiveSupport::NumberHelper.number_to_currency(rent_amount)} #{monthly? ? 'per month' : 'per year'}"
  end

  private

  def ends_after_start
    return if start_on.blank? || end_on.blank?

    errors.add(:end_on, "must be after the start date") if end_on <= start_on
  end

  def unit_is_free
    return if unit.nil?

    errors.add(:unit, "already has an active lease") if unit.leases.active.exists?
  end

  def sync_unit_occupancy
    unit.refresh_occupancy! unless unit.destroyed?
  end
end
