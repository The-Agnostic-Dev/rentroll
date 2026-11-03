module TenantsHelper
  # Everything the quick filter on the tenants page can match, lower-cased once
  # here so the browser only has to compare.
  def tenant_filter_text(tenant)
    units = tenant.leases.map { |lease| lease.unit.name }
    [ tenant.full_name, tenant.phone, tenant.email, *units ].compact.join(" ").downcase
  end

  def tenant_units(tenant)
    active = tenant.leases.select(&:active?)
    return "No current lease" if active.empty?

    safe_join(active.map { |lease| link_to(lease.unit.name, lease_path(lease)) }, tag.br)
  end
end
