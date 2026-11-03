require "test_helper"

class PaymentRecorderTest < ActiveSupport::TestCase
  setup do
    @lease = create_lease(frequency: "annual", rent_amount: 2_400_000, start_on: Date.current - 10)
  end

  test "issues receipt numbers in sequence" do
    first = PaymentRecorder.new(@lease, amount: 1_200_000, paid_on: Date.current, payment_method: "transfer").call
    second = PaymentRecorder.new(@lease, amount: 1_200_000, paid_on: Date.current, payment_method: "cash").call

    prefix = PaymentRecorder.receipt_prefix
    assert_equal "#{prefix}00001", first.receipt_no
    assert_equal "#{prefix}00002", second.receipt_no
  end

  test "remembers what was still owing after the payment" do
    payment = PaymentRecorder.new(@lease, amount: 1_000_000, paid_on: Date.current, payment_method: "pos").call

    assert_equal 1_400_000, payment.balance_after
  end

  test "keeps kobo" do
    payment = PaymentRecorder.new(@lease, amount: "85000.50", paid_on: Date.current, payment_method: "transfer").call

    assert_equal BigDecimal("85000.50"), payment.reload.amount
  end
end
