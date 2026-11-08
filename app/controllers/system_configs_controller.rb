class SystemConfigsController < ApplicationController
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_config, only: %i[show edit update destroy]

  def index
    @configs = SystemConfig.order(:config_key)
  end

  def show
  end

  def new
    @config = SystemConfig.new
  end

  def create
    @config = SystemConfig.new(config_params)
    if @config.save
      redirect_to @config, notice: "System config was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @config.update(config_params)
      redirect_to @config, notice: "System config was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @config.destroy
    redirect_to system_configs_url, notice: "System config was deleted."
  end

  private

  def set_config
    @config = SystemConfig.find_by!(config_key: params[:id])
  end

  def config_params
    params.require(:system_config).permit(:config_key, :config_value, :config_type, :description)
  end
end
