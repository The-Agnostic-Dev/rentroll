class TenantsController < ApplicationController
  before_action :set_tenant, only: %i[edit update]

  def index
    @tenants = Tenant.includes(leases: { unit: :property }).order(:full_name)
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(tenant_params)
    if @tenant.save
      redirect_to tenants_path, notice: "#{@tenant.full_name} added."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to tenants_path, notice: "#{@tenant.full_name} updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

  def tenant_params
    params.expect(tenant: [ :full_name, :email, :next_of_kin, :notes ])
  end
end
