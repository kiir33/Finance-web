module Api
  module V1
    class SystemConfigsController < ApplicationController
      def index
        configs = SystemConfig.all
        render json: { data: configs }, status: :ok
      end

      def show
        config = SystemConfig.find_by!(config_key: params[:key])
        render json: { data: config }, status: :ok
      end

      def create
        return unless admin_only!
        config = SystemConfig.new(system_config_params)
        if config.save
          render json: { data: config }, status: :created
        else
          render json: { error: { code: "invalid_config", message: config.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def update
        return unless admin_only!
        config = SystemConfig.find_by!(config_key: params[:key])
        if config.update(system_config_params)
          render json: { data: config }, status: :ok
        else
          render json: { error: { code: "invalid_config", message: config.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def destroy
        return unless admin_only!
        config = SystemConfig.find_by!(config_key: params[:key])
        config.destroy
        render json: { data: { message: "Config deleted" } }, status: :ok
      end

      private

      def system_config_params
        params.permit(:config_key, :config_value, :config_type, :description)
      end
    end
  end
end
