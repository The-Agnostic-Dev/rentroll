class Payment < ApplicationRecord
  METHODS = {
    "transfer" => "Bank transfer",
    "cash" => "Cash",
    "pos" => "POS",
    "cheque" => "Cheque"
  }.freeze

  belongs_to :lease
  has_one :tenant, through: :lease

  scope :received, -> { where(voided_at: nil) }
  scope :newest_first, -> { order(paid_on: :desc, id: :desc) }

  validates :amount, numericality: { greater_than: 0 }
  validates :paid_on, presence: true
  validates :payment_method, inclusion: { in: METHODS.keys }
  validates :receipt_no, presence: true
  validate :not_in_the_future

  after_commit -> { DashboardSummary.expire }, on: %i[create update destroy]

  def voided?
    voided_at.present?
  end

  def void!
    update!(voided_at: Time.current)
  end

  def method_label
    METHODS.fetch(payment_method, payment_method.to_s.humanize)
  end

  private

  def not_in_the_future
    return if paid_on.blank?

    errors.add(:paid_on, "can't be in the future") if paid_on > Date.current
  end
end
