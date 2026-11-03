# The payments list: newest first, a page at a time, with an optional
# payment method filter. Pages are cursor based so the list stays stable
# while new payments come in.
class PaymentFeed
  PER_PAGE = 25

  attr_reader :before, :payment_method

  def initialize(before: nil, payment_method: nil)
    @before = parse_date(before)
    @payment_method = payment_method.presence_in(Payment::METHODS.keys)
  end

  def payments
    @payments ||= begin
      scope = filtered.includes(lease: [ :tenant, { unit: :property } ]).newest_first
      scope = scope.where("payments.paid_on < ?", before) if before
      scope.limit(PER_PAGE).to_a
    end
  end

  def total_count
    filtered.count
  end

  def total_received
    filtered.received.sum(:amount)
  end

  def next_cursor
    return if payments.size < PER_PAGE

    payments.last.paid_on.iso8601
  end

  def first_page?
    before.nil?
  end

  private

  def filtered
    payment_method ? Payment.where(payment_method: payment_method) : Payment.all
  end

  def parse_date(value)
    Date.iso8601(value) if value.present?
  rescue Date::Error
    nil
  end
end
