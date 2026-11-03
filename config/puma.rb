# Puma configuration. Rentroll runs a single process with a few threads,
# which is plenty for one estate office.
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

port ENV.fetch("PORT", 5112)

plugin :tmp_restart

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
