class RenewalsController < ApplicationController
  WINDOW_DAYS = 90

  def index
    @window = (params[:days].presence || WINDOW_DAYS).to_i.clamp(7, 365)
    @leases = Lease.up_for_renewal(@window).includes(:tenant, unit: :property)
  end
end
