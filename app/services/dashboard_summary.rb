# Headline figures for the dashboard. Working these out walks every active
# lease's schedule, so the result is cached for a while and dropped when
# money comes in.
class DashboardSummary
  CACHE_KEY = "dashboard-summary"

  def self.current(today = Date.current)
    Rails.cache.fetch([ CACHE_KEY, today.iso8601 ], expires_in: 1.hour) { new(today).to_h }
  end

  def self.expire(today = Date.current)
    Rails.cache.delete([ CACHE_KEY, today.iso8601 ])
  end

  attr_reader :today

  def initialize(today = Date.current)
    @today = today
  end

  def to_h
    leases = Lease.active.includes(:payments).to_a
    month = today.all_month
    ledgers = leases.map { |lease| LeaseLedger.new(lease, today: today) }

    {
      expected_this_month: leases.sum { |lease| RentSchedule.new(lease).due_within(month).sum(&:amount) },
      collected_this_month: Payment.received.where(paid_on: month).sum(:amount),
      arrears_total: ledgers.sum(&:arrears),
      late_count: ledgers.count { |ledger| ledger.status == "Late" },
      occupied_units: Unit.occupied.count,
      total_units: Unit.count
    }
  end
end
