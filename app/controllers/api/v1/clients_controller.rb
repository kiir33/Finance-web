module Api
  module V1
    class ClientsController < ApplicationController
      def index
        clients = Client.where(deleted_at: nil)
        render json: { data: clients }, status: :ok
      end

      def show
        client = Client.find_by!(public_id: params[:id], deleted_at: nil)
        render json: { data: client }, status: :ok
      end

      def create
        client = Client.new(client_params)
        if client.save
          render json: { data: client }, status: :created
        else
          render json: { error: { code: "invalid_client", message: client.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def update
        client = Client.find_by!(public_id: params[:id], deleted_at: nil)
        if client.update(client_params)
          render json: { data: client }, status: :ok
        else
          render json: { error: { code: "invalid_client", message: client.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def destroy
        client = Client.find_by!(public_id: params[:id])
        client.update(deleted_at: Time.current)
        render json: { data: { message: "Client deleted" } }, status: :ok
      end

      private

      def client_params
        params.permit(:client_id, :name, :phone_number, :address, :user_id)
      end
    end
  end
end
