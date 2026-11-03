require "test_helper"

class RentScheduleTest < ActiveSupport::TestCase
  test "annual lease is due once a year on the start date" do
    lease = create_lease(frequency: "annual", start_on: Date.new(2025, 3, 15), end_on: Date.new(2027, 3, 15))

    assert_equal [ Date.new(2025, 3, 15), Date.new(2026, 3, 15) ], RentSchedule.new(lease).periods.map(&:due_on)
  end

  test "monthly lease is due on the same day each month" do
    lease = create_lease(frequency: "monthly", rent_amount: 150_000, start_on: Date.new(2026, 1, 10), end_on: Date.new(2026, 5, 10))
    periods = RentSchedule.new(lease).periods

    assert_equal %w[2026-01-10 2026-02-10 2026-03-10 2026-04-10], periods.map { |p| p.due_on.iso8601 }
    assert_equal Date.new(2026, 2, 9), periods.first.covers_until
  end

  test "stops charging after an early move-out" do
    lease = create_lease(frequency: "monthly", rent_amount: 150_000, start_on: Date.new(2026, 1, 10), end_on: Date.new(2027, 1, 10))
    lease.end_early!(on: Date.new(2026, 3, 20))

    assert_equal 3, RentSchedule.new(lease).periods.size
  end

  test "due_by only includes periods already due" do
    lease = create_lease(frequency: "monthly", rent_amount: 150_000, start_on: Date.new(2026, 1, 10), end_on: Date.new(2027, 1, 10))

    assert_equal 2, RentSchedule.new(lease).due_by(Date.new(2026, 3, 9)).size
  end
end
