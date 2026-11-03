# Matches a lease's payments against its rent schedule, oldest period first,
# and works out what is owed and how late it is.
class LeaseLedger
  Line = Data.define(:period, :paid, :outstanding, :status)

  attr_reader :lease, :today

  def initialize(lease, today: Date.current)
    @lease = lease
    @today = today
  end

  def schedule
    @schedule ||= RentSchedule.new(lease)
  end

  def lines
    @lines ||= allocate
  end

  def total_due
    schedule.due_by(today).sum(&:amount)
  end

  def total_paid
    received_payments.sum(&:amount)
  end

  # Positive when the tenant owes money, negative when they are in credit.
  def balance
    total_due - total_paid
  end

  def arrears
    [ balance, 0 ].max
  end

  def oldest_unpaid
    lines.find { |line| line.outstanding.positive? && line.period.due_on <= today }
  end

  # Days past the grace period for the oldest unpaid rent; 0 when not late.
  def days_late
    line = oldest_unpaid
    return 0 unless line

    [ (today - (line.period.due_on + Lease::GRACE_DAYS)).to_i, 0 ].max
  end

  def status
    if arrears.zero?
      balance.negative? ? "In credit" : "Paid up"
    elsif days_late.positive?
      "Late"
    else
      "In grace"
    end
  end

  private

  def received_payments
    @received_payments ||= lease.payments.reject(&:voided?)
  end

  def allocate
    pot = total_paid
    schedule.periods.map do |period|
      paid = [ pot, period.amount ].min
      pot -= paid
      outstanding = period.amount - paid
      Line.new(period: period, paid: paid, outstanding: outstanding, status: line_status(period, outstanding))
    end
  end

  def line_status(period, outstanding)
    return "Paid" if outstanding.zero?
    return "Upcoming" if period.due_on > today
    return "Late" if today > period.due_on + Lease::GRACE_DAYS
    outstanding < period.amount ? "Part paid" : "Due"
  end
end
