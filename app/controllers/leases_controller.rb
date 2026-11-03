class LeasesController < ApplicationController
  before_action :set_lease, only: %i[show destroy end_early]

  def show
    @ledger = @lease.ledger
    @payments = @lease.payments.to_a.reverse
    @payment = Payment.new(paid_on: Date.current, amount: @ledger.oldest_unpaid&.outstanding,
                           receipt_no: PaymentRecorder.next_receipt_no)
  end

  def new
    unit = Unit.find_by(id: params[:unit_id])
    @lease = Lease.new(
      unit: unit,
      start_on: Date.current,
      end_on: Date.current + 1.year,
      frequency: unit&.kind == "shop" ? "monthly" : "annual",
      rent_amount: unit&.listed_rent
    )
  end

  def create
    @lease = Lease.new(lease_params)
    if @lease.save
      redirect_to @lease, notice: "Lease created for #{@lease.tenant.full_name}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    if @lease.destroy
      redirect_to property_path(@lease.unit.property_id), notice: "Lease deleted."
    else
      redirect_to @lease, alert: "This lease has payments recorded against it, so it can't be deleted. End it instead."
    end
  end

  def end_early
    moved_out_on = params.dig(:lease, :ended_on).presence&.to_date || Date.current
    @lease.end_early!(on: moved_out_on)
    redirect_to @lease, notice: "Lease ended. #{@lease.unit.label} is now free to let."
  end

  private

  def set_lease
    @lease = Lease.find(params[:id])
  end

  def lease_params
    params.expect(lease: [ :unit_id, :tenant_id, :start_on, :end_on, :frequency, :rent_amount, :deposit ])
  end
end
