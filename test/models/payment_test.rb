require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  setup do
    @lease = create_lease(start_on: Date.current - 30)
  end

  test "a payment cannot be dated in the future" do
    payment = PaymentRecorder.new(@lease, amount: 10_000, paid_on: Date.current + 2, payment_method: "cash").call

    assert_not payment.persisted?
    assert_includes payment.errors[:paid_on], "can't be in the future"
  end

  test "amount must be positive" do
    payment = PaymentRecorder.new(@lease, amount: 0, paid_on: Date.current, payment_method: "cash").call

    assert_not payment.persisted?
  end

  test "method label" do
    assert_equal "Bank transfer", Payment.new(payment_method: "transfer").method_label
  end
end
