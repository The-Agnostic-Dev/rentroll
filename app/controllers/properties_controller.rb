class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:units).order(:name)
  end

  def show
    @property = Property.find(params[:id])
    @units = @property.units.includes(leases: :tenant)
  end
end
