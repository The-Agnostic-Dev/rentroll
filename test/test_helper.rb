ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Small builders instead of fixtures: each test sets up exactly the lease it talks about.
    def create_property(name: "Adeola Court")
      Property.create!(name: name, address: "14 Adeola Hopewell Street", area: "Victoria Island")
    end

    def create_unit(property: create_property, label: "Flat 1A", kind: "flat", listed_rent: 2_400_000)
      property.units.create!(label: label, kind: kind, listed_rent: listed_rent)
    end

    def create_tenant(full_name: "Adebayo Ogunleye", phone: "0803 412 7781")
      Tenant.create!(full_name: full_name, phone: phone)
    end

    def create_lease(unit: create_unit, tenant: create_tenant, frequency: "annual", rent_amount: 2_400_000,
                     start_on: Date.new(2026, 3, 15), end_on: nil)
      Lease.create!(unit: unit, tenant: tenant, frequency: frequency, rent_amount: rent_amount,
                    start_on: start_on, end_on: end_on || start_on + 1.year)
    end
  end
end

module SignInHelper
  def sign_in_as(user = nil)
    user ||= User.create!(name: "Tolu Okoro", email: "tolu@okoroestates.ng", password: "rentroll2026")
    post session_path, params: { email: user.email, password: "rentroll2026" }
    user
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
