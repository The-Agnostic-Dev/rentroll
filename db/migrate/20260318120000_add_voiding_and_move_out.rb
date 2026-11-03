class AddVoidingAndMoveOut < ActiveRecord::Migration[8.1]
  def change
    add_column :payments, :voided_at, :datetime
    add_column :payments, :balance_after, :decimal, precision: 12, scale: 2
    add_column :leases, :ended_on, :date
  end
end
