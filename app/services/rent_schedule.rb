# Works out when rent falls due over the life of a lease.
#
# Rent is paid in advance: the first period is due on the lease start date and
# every following period one month (monthly leases) or one year (annual leases)
# after the previous one. A lease that ended early stops charging after the
# move-out date.
class RentSchedule
  Period = Data.define(:number, :due_on, :covers_until, :amount)

  attr_reader :lease

  def initialize(lease)
    @lease = lease
  end

  def periods
    @periods ||= build_periods
  end

  def due_by(date)
    periods.select { |period| period.due_on <= date }
  end

  def due_within(range)
    periods.select { |period| range.cover?(period.due_on) }
  end

  def next_due_after(date)
    periods.find { |period| period.due_on > date }
  end

  private

  def step
    lease.monthly? ? 1.month : 1.year
  end

  def build_periods
    return [] if lease.start_on.blank? || lease.end_on.blank?

    list = []
    due_on = lease.start_on
    while due_on < lease.end_on && (lease.ended_on.nil? || due_on <= lease.ended_on)
      next_due = due_on + step
      list << Period.new(
        number: list.size + 1,
        due_on: due_on,
        covers_until: [ next_due - 1.day, lease.end_on ].min,
        amount: lease.rent_amount
      )
      due_on = next_due
    end
    list
  end
end
