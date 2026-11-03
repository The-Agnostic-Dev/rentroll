class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :lease, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.date :paid_on, null: false
      t.string :payment_method, null: false, default: "transfer"
      t.string :reference
      t.string :receipt_no, null: false
      t.timestamps
    end
    add_index :payments, :paid_on
    add_index :payments, :receipt_no
  end
end
