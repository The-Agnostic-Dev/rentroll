class DashboardController < ApplicationController
  def show
    @summary = DashboardSummary.current
    @renewals = Lease.up_for_renewal(RenewalsController::WINDOW_DAYS)
      .includes(:tenant, unit: :property)
    @recent_payments = Payment.includes(lease: [ :tenant, { unit: :property } ]).newest_first.limit(6)
  end
end
