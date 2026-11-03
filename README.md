# Rentroll

Rentroll is the rent book for Okoro Estates, a small letting office in Lagos. It keeps track of
the properties we manage, the flats, shops and offices in them, who rents each one, what they owe,
what they have paid and whose lease is coming up for renewal. The estate manager and the admin
assistant use it every day to record payments, print receipts and chase arrears.

Everything is in naira (shown like ₦150,000.00) and every date is a Lagos date (`Africa/Lagos`).

## Stack

- Ruby 3.3, Rails 8.1
- SQLite (one file, no other services)
- Hotwire (Turbo + Stimulus) with importmap, no Node build step
- Minitest

## Running it

### Natively

```sh
bin/setup --skip-server     # installs gems, creates the database and loads the demo data
bin/rails server            # http://localhost:5112
```

`bin/rails db:seed` reloads the demo data at any time. It wipes the demo tables first and works out
every date from today, so arrears, grace periods and renewals look the same whichever day you run it.
Set `RENTROLL_DB=/some/path.sqlite3` to use a different database file.

### With Docker

```sh
docker compose up --build   # http://localhost:5112
```

The container runs in production mode and reloads the demo data every time it starts.

### Demo logins

| Who | Email | Password |
| --- | --- | --- |
| Tolu Okoro (estate manager) | `tolu@okoroestates.ng` | `rentroll2026` |
| Ngozi Eze (admin assistant) | `ngozi@okoroestates.ng` | `rentroll2026` |

## Tests

```sh
bin/rails test
```

Tests build the records they need with the small helpers in `test/test_helper.rb` (no fixtures).

## How rent works in Rentroll

These rules come up a lot in questions from the office, so they are written down here.

- **Rent is paid in advance.** The first rent is due on the day the lease starts. After that it is
  due every month (monthly leases) or every year (annual leases) on the same date. A lease page
  shows the full schedule with what has been paid against each date. A monthly lease that starts
  on the 29th, 30th or 31st falls due on the last day of shorter months (February, April, ...) and
  back on its own day in the months that have it.
- **Payments go to the oldest rent first.** A part payment reduces the oldest unpaid period;
  anything paid beyond what is due shows as credit.
- **Five-day grace period.** Unpaid rent shows as *In grace* (or *Due* on the lease schedule) for
  the first 5 days after its due date and only becomes *Late* on day 6. "Days late" on the arrears
  page are counted from the end of the grace period, not from the due date. The dashboard's late
  count only includes tenants past the grace period, while "Outstanding arrears" includes everything
  owed today, in grace or not.
- **Expected this month** on the dashboard is the rent falling due during the current calendar month.
  A monthly lease counts every month; an annual lease only counts in the month its rent year starts
  (its anniversary month). In most months it is therefore well below the sum of all the rents.
- **Collected this month** is the total of payments dated in the current month, leaving out voided
  receipts.
- **Receipts** are numbered per year, `RR-2026-00001` upwards. The record-payment form shows the
  number the payment will get, so it can be copied onto the paper receipt book. A wrong receipt is *voided* (it stays
  on file, struck through, and stops counting). "Delete" is only for entries made by mistake.
  To reprint a receipt, open it from the lease page or the Payments list and use "Print receipt".
- **Ending a lease early** (tenant moving out): open the lease, "Tenant moving out?", pick the
  move-out date. Rent stops being charged after that date and the unit becomes available to let again.
- **Renewals** lists active leases ending in the next 90 days (30, 60 and 180 are available too), so
  the office can call tenants early.

## Where things live

```
app/models/          Property, Unit, Tenant, Lease, Payment, User
app/services/        RentSchedule      due dates for a lease
                     LeaseLedger       matches payments to the schedule: balance, status, days late
                     PaymentRecorder   records a payment and issues the receipt number
                     PaymentFeed       the Payments list (filter and paging)
                     DashboardSummary  headline figures, cached for an hour
app/controllers/     one controller per screen
app/javascript/      Stimulus controllers (tenant quick filter, receipt printing)
db/seeds.rb          demo data for Okoro Estates
```

Signing in is a plain email and password form (`app/controllers/concerns/authentication.rb`); there
is no sign-up, staff accounts are created from the console.
