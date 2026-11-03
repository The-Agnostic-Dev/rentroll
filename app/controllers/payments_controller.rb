class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[show edit update void destroy]

  def index
    @feed = PaymentFeed.new(before: params[:before], payment_method: params[:payment_method])
  end

  def show
  end

  def create
    @lease = Lease.find(params[:lease_id])
    @payment = PaymentRecorder.new(@lease, payment_params).call

    if @payment
      redirect_to lease_path(@lease), notice: "Payment recorded. Receipt #{@payment.receipt_no}."
    else
      redirect_to lease_path(@lease), alert: "Payment not recorded: #{@payment.errors.full_messages.to_sentence}."
    end
  end

  def edit
  end

  def update
    if @payment.update(payment_params)
      redirect_to payment_path(@payment), notice: "Payment updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def void
    @payment.void!
    redirect_to lease_path(@payment.lease), notice: "Receipt #{@payment.receipt_no} voided."
  end

  def destroy
    lease = @payment.lease
    @payment.destroy!
    redirect_to lease_path(lease), notice: "Payment deleted."
  end

  private

  def set_payment
    @payment = Payment.find(params[:id])
  end

  def payment_params
    params.expect(payment: [ :amount, :paid_on, :payment_method, :reference, :receipt_no ])
  end
end
