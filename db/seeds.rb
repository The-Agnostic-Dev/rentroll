# Demo data for Okoro Estates, a small Lagos letting office.
# Dates are worked out from today so the arrears, grace periods and renewals
# always look the same whatever day the app is started.
#
# Safe to re-run: it clears the demo tables first.

today = Date.current
rng = Random.new(2026)

Payment.delete_all
Lease.delete_all
Tenant.delete_all
Unit.delete_all
Property.delete_all
User.delete_all

User.create!(name: "Tolu Okoro", email: "tolu@okoroestates.ng", password: "rentroll2026")
User.create!(name: "Ngozi Eze", email: "ngozi@okoroestates.ng", password: "rentroll2026")

properties = {
  adeola: Property.create!(name: "Adeola Court", address: "14 Adeola Hopewell Street", area: "Victoria Island"),
  palm: Property.create!(name: "Palm Grove Apartments", address: "7 Bode Thomas Street", area: "Surulere"),
  allen: Property.create!(name: "Allen Avenue Plaza", address: "52 Allen Avenue", area: "Ikeja")
}

unit_specs = {
  adeola: [ [ "Flat 1A", "flat", 4_500_000 ], [ "Flat 1B", "flat", 4_500_000 ], [ "Flat 2A", "flat", 4_800_000 ],
            [ "Flat 2B", "flat", 4_800_000 ], [ "Penthouse", "flat", 9_000_000 ] ],
  palm: [ [ "Flat 1", "flat", 1_800_000 ], [ "Flat 2", "flat", 1_800_000 ], [ "Flat 3", "flat", 1_950_000 ],
          [ "Flat 4", "flat", 1_950_000 ], [ "Flat 5", "flat", 2_100_000 ], [ "Flat 6", "flat", 2_100_000 ] ],
  allen: [ [ "Shop 1", "shop", 150_000 ], [ "Shop 2", "shop", 150_000 ], [ "Shop 3", "shop", 175_000 ],
           [ "Shop 4", "shop", 175_000 ], [ "Office 1", "office", 3_200_000 ], [ "Office 2", "office", 3_200_000 ] ]
}

units = {}
unit_specs.each do |key, specs|
  specs.each do |label, kind, rent|
    units[label] = properties[key].units.create!(label: label, kind: kind, listed_rent: rent)
  end
end

tenant = ->(name, phone, email = nil, kin = nil) { Tenant.create!(full_name: name, phone: phone, email: email, next_of_kin: kin) }

# Most recent 31st of a month that is at least five months back.
month_end = (today << 5).end_of_month
month_end = (month_end << 1).end_of_month until month_end.day == 31

leases = [
  # [unit, tenant, frequency, rent, start_on, months_long, payment behaviour]
  [ "Flat 1A", tenant.("Adebayo Ogunleye", "0803 412 7781", "adebayo.ogunleye@gmail.com", "Funke Ogunleye 0805 112 9033"), "annual", 4_500_000, today - 300, 24, :prompt ],
  [ "Flat 1B", tenant.("Chiamaka Nwosu", "0816 330 2214", "chiamaka.nwosu@yahoo.com"), "annual", 4_500_000, (today - 3) << 12, 24, :prompt ],
  [ "Flat 2A", tenant.("Emeka Okafor", "0809 555 1902", nil, "Ifeoma Okafor 0803 998 1200"), "annual", 4_800_000, today - 330, 12, :prompt ],
  [ "Penthouse", tenant.("Halima Bello", "0802 777 4410", "halima@bellogroup.ng"), "annual", 9_000_000, today - 350, 12, :prompt ],
  [ "Flat 1", tenant.("Tunde Bakare", "0813 204 6655"), "monthly", 150_000, today - 3 - 9.months, 12, :prompt ],
  [ "Flat 2", tenant.("Ngozi Adeyemi", "0706 118 3390", "ngozi.adeyemi@gmail.com"), "monthly", 150_000, today - 17 - 7.months, 12, :behind ],
  [ "Flat 3", tenant.("Ibrahim Musa", "0805 662 0071"), "annual", 1_950_000, today - 280, 12, :part ],
  [ "Flat 5", tenant.("Folake Johnson", "0818 909 4432", "folakej@outlook.com"), "monthly", 175_000, today - 2 - 5.months, 12, :prompt ],
  [ "Flat 6", tenant.("Uche Eze", "0807 321 5566"), "annual", 2_100_000, today - 300, 12, :prompt ],
  [ "Shop 1", tenant.("Kemi's Fabrics (Kemi Alade)", "0803 777 2020", "kemifabrics@gmail.com"), "monthly", 150_000, today - 11.months + 4, 24, :prompt ],
  [ "Shop 2", tenant.("Chukwudi Obi", "0812 450 8890", nil, "Ada Obi 0703 210 4455"), "monthly", 150_000, month_end, 12, :prompt ],
  [ "Shop 3", tenant.("Mama Put Express (Bisi Lawal)", "0909 112 3344"), "monthly", 175_000, today - 9 - 6.months, 12, :behind ],
  [ "Office 1", tenant.("Zenith Logistics Ltd", "0201 270 4400", "accounts@zenithlogistics.ng"), "annual", 3_200_000, today - 335, 12, :prompt ]
]

tenant.("Grace Etim", "0814 223 9087", "grace.etim@gmail.com")
tenant.("Yusuf Abdullahi", "0803 145 6672")

methods = %w[transfer transfer transfer pos cash cheque]

leases.each do |label, who, frequency, rent, start_on, months, behaviour|
  lease = Lease.create!(unit: units[label], tenant: who, frequency: frequency, rent_amount: rent,
                        deposit: frequency == "monthly" ? rent : rent / 10, start_on: start_on,
                        end_on: start_on + months.months)

  due = RentSchedule.new(lease).due_by(today)
  due.each_with_index do |period, index|
    last = index == due.size - 1
    next if behaviour == :behind && index >= due.size - 2
    next if last && today - period.due_on <= 3

    amounts = behaviour == :part && last ? [ (rent * 0.6).round(-3) ] : [ rent ]
    amounts = [ rent / 2, rent / 2 ] if frequency == "annual" && behaviour == :prompt && index.odd?
    amounts.each_with_index do |amount, part|
      paid_on = [ period.due_on + (frequency == "monthly" ? rng.rand(0..1) : rng.rand(0..6)) + part * 20, today ].min
      PaymentRecorder.new(lease, amount: amount, paid_on: paid_on, payment_method: methods.sample(random: rng),
                                 reference: "TRF/#{rng.rand(100_000..999_999)}").call
    end
  end
end

# Ngozi typed one transfer in twice last month and voided the copy.
duplicate = Payment.where(lease: Lease.joins(:unit).where(units: { label: "Shop 1" })).order(:paid_on).last
if duplicate
  copy = PaymentRecorder.new(duplicate.lease, amount: duplicate.amount, paid_on: duplicate.paid_on,
                                              payment_method: duplicate.payment_method, reference: duplicate.reference).call
  copy.void!
end

puts "Seeded #{Property.count} properties, #{Unit.count} units, #{Lease.count} leases, #{Payment.count} payments."
