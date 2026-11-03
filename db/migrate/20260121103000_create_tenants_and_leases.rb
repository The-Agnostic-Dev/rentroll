class CreateTenantsAndLeases < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :full_name, null: false
      t.string :phone
      t.string :email
      t.string :next_of_kin
      t.text :notes
      t.timestamps
    end

    create_table :leases do |t|
      t.references :unit, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.date :start_on, null: false
      t.date :end_on, null: false
      t.string :frequency, null: false, default: "annual"
      t.decimal :rent_amount, precision: 12, scale: 2, null: false
      t.decimal :deposit, precision: 12, scale: 2, null: false, default: 0
      t.string :status, null: false, default: "active"
      t.timestamps
    end
  end
end
