class Tenant < ApplicationRecord
  has_many :leases, dependent: :restrict_with_error
  has_many :payments, through: :leases

  normalizes :phone, with: ->(phone) { phone.squish }
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :full_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  def current_lease
    leases.active.order(start_on: :desc).first
  end
end
