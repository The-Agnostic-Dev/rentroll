require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as
    @lease = create_lease(start_on: Date.current - 40)
    PaymentRecorder.new(@lease, amount: 1_000_000, paid_on: Date.current - 5, payment_method: "transfer").call
  end

  test "main pages render" do
    [ root_path, properties_path, property_path(@lease.unit.property), tenants_path, payments_path,
      arrears_path, renewals_path, lease_path(@lease), new_lease_path ].each do |path|
      get path
      assert_response :success, "expected #{path} to render"
    end
  end

  test "recording a payment from the lease page" do
    assert_difference -> { @lease.payments.count }, 1 do
      post lease_payments_path(@lease), params: { payment: { amount: "500000", paid_on: Date.current, payment_method: "cash" } }
    end
    assert_redirected_to lease_path(@lease)
  end

  test "receipt page shows the amount" do
    get payment_path(@lease.payments.first)
    assert_select ".receipt-amount", "₦1,000,000.00"
  end

  test "renaming a tenant" do
    patch tenant_path(@lease.tenant), params: { tenant: { full_name: "Adebayo O. Ogunleye" } }
    assert_redirected_to tenants_path
    assert_equal "Adebayo O. Ogunleye", @lease.tenant.reload.full_name
  end

  test "creating a lease on a vacant unit" do
    unit = create_unit(property: @lease.unit.property, label: "Flat 9")
    post leases_path, params: { lease: { unit_id: unit.id, tenant_id: @lease.tenant_id, frequency: "monthly",
                                         rent_amount: "150000", start_on: Date.current, end_on: Date.current + 1.year } }
    assert_redirected_to lease_path(Lease.last)
    assert unit.reload.occupied?
  end
end
