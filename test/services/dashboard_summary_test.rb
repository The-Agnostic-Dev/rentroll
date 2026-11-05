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

  test "voiding a payment expires dashboard summary cache" do
    payment = PaymentRecorder.new(@lease, amount: 100000, paid_on: Date.current, payment_method: "transfer", reference: "TEST1").call
    populate_cache
    assert Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
    payment.void!
    refute Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
  end

  test "updating a payment expires dashboard summary cache" do
    payment = PaymentRecorder.new(@lease, amount: 100000, paid_on: Date.current, payment_method: "transfer", reference: "TEST2").call
    populate_cache
    assert Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
    payment.update!(amount: 50000)
    refute Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
  end

  test "destroying a payment expires dashboard summary cache" do
    payment = PaymentRecorder.new(@lease, amount: 100000, paid_on: Date.current, payment_method: "transfer", reference: "TEST3").call
    populate_cache
    assert Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
    payment.destroy
    refute Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
  end

  test "ending a lease early expires dashboard summary cache" do
    populate_cache
    assert Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
    @lease.end_early!
    refute Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
  end

  test "destroying a lease expires dashboard summary cache" do
    populate_cache
    assert Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
    @lease.destroy
    refute Rails.cache.exist?([DashboardSummary::CACHE_KEY, Date.current.iso8601])
  end
end
