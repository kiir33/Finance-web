class ClientsController < ApplicationController
  include ConcurrencyHandling
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = visible_clients.order(:client_id)
  end

  def show
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to @client, notice: "Client was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @force_update_retry
      # Bypass optimistic locking for concurrent edit "Save Anyway"
      permitted = client_params.except(:lock_version, :force_update).to_h
      if @client.update_columns(permitted)
        redirect_to @client, notice: "Client was updated (overwrote concurrent changes)."
      else
        render :edit, status: :unprocessable_entity
      end
    elsif @client.update(client_params)
      redirect_to @client, notice: "Client was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.update(deleted_at: Time.current)
    redirect_to clients_url, notice: "Client was archived."
  end

  private

  def set_client
    @client = visible_clients.find(params[:id])
  end

  # Admins can see every client; members are limited to clients linked to their account.
  def visible_clients
    scope = Client.where(deleted_at: nil)
    current_user.admin? ? scope : scope.where(user_id: current_user.id)
  end

  def client_params
    params.require(:client).permit(:client_id, :name, :phone_number, :address, :user_id, :lock_version, :force_update)
  end
end
