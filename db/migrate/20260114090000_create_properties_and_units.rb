class CreatePropertiesAndUnits < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.timestamps
    end

    create_table :properties do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :area
      t.timestamps
    end

    create_table :units do |t|
      t.references :property, null: false, foreign_key: true
      t.string :label, null: false
      t.string :kind, null: false, default: "flat"
      t.decimal :listed_rent, precision: 12, scale: 2
      t.string :status, null: false, default: "vacant"
      t.timestamps
    end
    add_index :units, [ :property_id, :label ], unique: true
  end
end
