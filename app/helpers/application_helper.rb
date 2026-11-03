module ApplicationHelper
  def naira(amount)
    number_to_currency(amount || 0)
  end

  def short_date(date)
    date ? l(date) : "None"
  end

  def date_cell(date)
    tag.time(short_date(date), datetime: date&.iso8601)
  end

  BADGE_TONES = {
    "Paid" => "good", "Paid up" => "good", "In credit" => "good", "Vacant" => "muted",
    "Occupied" => "good", "Upcoming" => "muted", "Due" => "warn", "Part paid" => "warn",
    "In grace" => "warn", "Late" => "bad", "Voided" => "muted", "Ended" => "muted", "Active" => "good"
  }.freeze

  def badge(text)
    tag.span(text, class: [ "badge", "badge-#{BADGE_TONES.fetch(text, 'muted')}" ])
  end

  def nav_link(label, path)
    active = current_page?(path) || (path != root_path && request.path.start_with?(path))
    link_to label, path, class: [ "nav-link", { "is-active" => active } ]
  end

  def expiry_phrase(lease)
    days = lease.days_to_expiry
    case days
    when 0 then "ends today"
    when 1 then "ends tomorrow"
    else "ends in #{days} days"
    end
  end
end
