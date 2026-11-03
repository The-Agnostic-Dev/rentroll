require "test_helper"

class LeaseLedgerTest < ActiveSupport::TestCase
  setup do
    @lease = create_lease(frequency: "monthly", rent_amount: 150_000, start_on: Date.new(2026, 1, 10), end_on: Date.new(2027, 1, 10))
  end

  def pay(amount, on)
    PaymentRecorder.new(@lease, amount: amount, paid_on: on, payment_method: "transfer").call.tap { |p| assert p.persisted? }
  end

  test "paid up when every due period is covered" do
    travel_to Date.new(2026, 2, 12) do
      pay(150_000, Date.new(2026, 1, 10))
      pay(150_000, Date.new(2026, 2, 11))

      ledger = LeaseLedger.new(@lease.reload)
      assert_equal 0, ledger.arrears
      assert_equal "Paid up", ledger.status
    end
  end

  test "unpaid rent is in grace for five days, then late" do
    pay(150_000, Date.new(2026, 1, 10))

    assert_equal "In grace", LeaseLedger.new(@lease.reload, today: Date.new(2026, 2, 15)).status
    late = LeaseLedger.new(@lease, today: Date.new(2026, 2, 18))
    assert_equal "Late", late.status
    assert_equal 3, late.days_late
    assert_equal 150_000, late.arrears
  end

  test "voided payments do not count" do
    travel_to Date.new(2026, 1, 20) do
      pay(150_000, Date.new(2026, 1, 10)).void!

      assert_equal 150_000, LeaseLedger.new(@lease.reload).arrears
    end
  end

  test "payments are applied to the oldest rent first" do
    travel_to Date.new(2026, 2, 12) do
      pay(200_000, Date.new(2026, 2, 11))
      lines = LeaseLedger.new(@lease.reload).lines

      assert_equal "Paid", lines[0].status
      assert_equal 100_000, lines[1].outstanding
    end
  end
end
