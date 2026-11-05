require "test_helper"

class DashboardSummaryTest < ActiveSupport::TestCase
  test "occupied_units counts only units with an active lease covering today" do
    flat4 = Unit.find_by!(label: "Flat 4")
    shop4 = Unit.find_by!(label: "Shop 4")
    office2 = Unit.find_by!(label: "Office 2")

    tenant_a = Tenant.create!(full_name: "Current Lease Tenant", phone: "0800 000 0001")
    tenant_b = Tenant.create!(full_name: "Expired Lease Tenant", phone: "0800 000 0002")
    tenant_c = Tenant.create!(full_name: "Ended Lease Tenant", phone: "0800 000 0003")

    Lease.create!(
      unit: flat4,
      tenant: tenant_a,
      frequency: "monthly",
      rent_amount: 100_000,
      deposit: 100_000,
      start_on: Date.current - 10,
      end_on: Date.current + 10
    )

    Lease.create!(
      unit: shop4,
      tenant: tenant_b,
      frequency: "monthly",
      rent_amount: 100_000,
      deposit: 100_000,
      start_on: Date.current - 100,
      end_on: Date.current - 10
    )

    lease_c = Lease.create!(
      unit: office2,
      tenant: tenant_c,
      frequency: "monthly",
      rent_amount: 100_000,
      deposit: 100_000,
      start_on: Date.current - 50,
      end_on: Date.current + 50
    )

    summary = DashboardSummary.new.to_h
    assert_equal 15, summary[:occupied_units],
      "occupied_units should include the current lease and the soon-to-be-ended lease, but not the expired one"

    lease_c.end_early!

    summary = DashboardSummary.new.to_h
    assert_equal 14, summary[:occupied_units],
      "occupied_units should drop after ending a lease early"
  end
end
