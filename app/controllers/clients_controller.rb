class ClientsController < ApplicationController
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.where(deleted_at: nil).order(:client_id)
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
    if @client.update(client_params)
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
    @client = Client.where(deleted_at: nil).find(params[:id])
  end

  def client_params
    params.require(:client).permit(:client_id, :name, :phone_number, :address, :user_id)
  end
end
