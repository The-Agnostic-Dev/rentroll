# Records a rent payment against a lease and issues its receipt number.
#
# Receipt numbers run per calendar year: RR-2026-00001, RR-2026-00002, ...
# The record-payment form shows the number the payment will get, so the office
# can copy it onto the paper receipt book; that same number is kept on save.
class PaymentRecorder
  attr_reader :lease, :attributes

  def self.receipt_prefix(year = Date.current.year)
    "RR-#{year}-"
  end

  def self.next_receipt_no
    prefix = receipt_prefix
    last = Payment.where("receipt_no LIKE ?", "#{prefix}%").maximum(:receipt_no)
    sequence = last ? last.delete_prefix(prefix).to_i + 1 : 1
    format("%s%05d", prefix, sequence)
  end

  def initialize(lease, attributes)
    @lease = lease
    @attributes = attributes
  end

  def call
    payment = Payment.new(attributes.merge(lease: lease))
    payment.receipt_no = self.class.next_receipt_no if payment.receipt_no.blank?
    payment.balance_after = LeaseLedger.new(lease).balance - payment.amount if payment.amount
    lease.payments.reset if payment.save
    payment
  end
end
