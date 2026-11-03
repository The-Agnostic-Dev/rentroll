class ArrearsController < ApplicationController
  def index
    leases = Lease.active.includes(:payments, :tenant, unit: :property)
    leases = leases.joins(:unit).where(units: { property_id: params[:property_id] }) if params[:property_id].present?
    @properties = Property.order(:name)
    @rows = leases.map(&:ledger).select { |ledger| ledger.arrears.positive? }
      .sort_by { |ledger| [ -ledger.arrears, ledger.lease.tenant.full_name ] }
    @total = @rows.sum(&:arrears)
  end
end
