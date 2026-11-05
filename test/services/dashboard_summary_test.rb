require 'test_helper'

class DashboardSummaryTest < ActiveSupport::TestCase
  setup do
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    @property = Property.create!(name: "Test Property", address: "123 Test St", area: "Test Area")
    @unit = @property.units.create!(label: "Test Unit", kind: "flat", listed_rent: 100000)
    @tenant = Tenant.create!(full_name: "Test Tenant", phone: "0800 000 0000")
    @lease = Lease.create!(
      unit: @unit,
      tenant: @tenant,
      frequency: "monthly",
      rent_amount: 100000,
      deposit: 100000,
      start_on: Date.current - 1.month,
      end_on: Date.current + 11.months
    )
  end

  def populate_cache
    DashboardSummary.current
  end

  test "voiding a payment updates dashboard totals" do
    payment = PaymentRecorder.new(@lease, amount: 100000, paid_on: Date.current, payment_method: "transfer", reference: "TEST1").call
    summary_before = DashboardSummary.current
    collected_before = summary_before.collected_this_month
    payment.void!
    summary_after = DashboardSummary.current
    assert_equal collected_before - 100000, summary_after.collected_this_month
  end

  test "updating a payment updates dashboard totals" do
    payment = PaymentRecorder.new(@lease, amount: 100000, paid_on: Date.current, payment_method: "transfer", reference: "TEST2").call
    summary_before = DashboardSummary.current
    collected_before = summary_before.collected_this_month
    payment.update!(amount: 50000)
    summary_after = DashboardSummary.current
    assert_equal collected_before - 50000, summary_after.collected_this_month
  end

  test "destroying a payment updates dashboard totals" do
    payment = PaymentRecorder.new(@lease, amount: 100000, paid_on: Date.current, payment_method: "transfer", reference: "TEST3").call
    summary_before = DashboardSummary.current
    collected_before = summary_before.collected_this_month
    payment.destroy
    summary_after = DashboardSummary.current
    assert_equal collected_before - 100000, summary_after.collected_this_month
  end

  test "ending a lease early updates dashboard totals" do
    summary_before = DashboardSummary.current
    @lease.end_early!(on: Date.current)
    summary_after = DashboardSummary.current
    assert_not_equal summary_before.to_h, summary_after.to_h
  end

  test "destroying a lease updates dashboard totals" do
    summary_before = DashboardSummary.current
    @lease.destroy
    summary_after = DashboardSummary.current
    assert_not_equal summary_before.to_h, summary_after.to_h
  end
end
