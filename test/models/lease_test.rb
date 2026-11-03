require "test_helper"

class LeaseTest < ActiveSupport::TestCase
  test "end date must come after the start date" do
    lease = Lease.new(unit: create_unit, tenant: create_tenant, frequency: "annual", rent_amount: 1_000_000,
                      start_on: Date.new(2026, 5, 1), end_on: Date.new(2026, 4, 1))

    assert_not lease.valid?
    assert_includes lease.errors[:end_on], "must be after the start date"
  end

  test "a unit can only have one active lease" do
    unit = create_unit
    create_lease(unit: unit)
    second = Lease.new(unit: unit, tenant: create_tenant(full_name: "Chiamaka Nwosu"), frequency: "annual",
                       rent_amount: 1_000_000, start_on: Date.current, end_on: Date.current + 1.year)

    assert_not second.valid?
  end

  test "letting a unit marks it occupied" do
    unit = create_unit
    create_lease(unit: unit)

    assert unit.reload.occupied?
  end

  test "renewals are leases ending inside the window" do
    soon = create_lease(start_on: Date.current - 300, end_on: Date.current + 20)
    create_lease(unit: create_unit(label: "Flat 2"), start_on: Date.current - 10, end_on: Date.current + 355)

    assert_equal [ soon ], Lease.up_for_renewal(90).to_a
  end
end
