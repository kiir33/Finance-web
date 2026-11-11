module Api
  module V1
    class MembersController < ApplicationController
      def index
        members = Member.where(deleted_at: nil)
        render json: { data: members }, status: :ok
      end

      def show
        member = Member.find_by!(public_id: params[:id], deleted_at: nil)
        render json: { data: member }, status: :ok
      end

      def create
        member = Member.new(member_params)
        if member.save
          render json: { data: member }, status: :created
        else
          render json: { error: { code: "invalid_member", message: member.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def update
        member = Member.find_by!(public_id: params[:id], deleted_at: nil)
        if member.update(member_params)
          render json: { data: member }, status: :ok
        else
          render json: { error: { code: "invalid_member", message: member.errors.full_messages.join(", ") } }, status: :unprocessable_entity
        end
      end

      def destroy
        member = Member.find_by!(public_id: params[:id])
        member.update(deleted_at: Time.current)
        render json: { data: { message: "Member deleted" } }, status: :ok
      end

      private

      def member_params
        params.permit(:member_id, :name, :phone_number, :address, :user_id)
      end
    end
  end
end
