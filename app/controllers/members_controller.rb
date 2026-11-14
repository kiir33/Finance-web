class MembersController < ApplicationController
  include ConcurrencyHandling
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_member, only: %i[show edit update destroy]

  def index
    @members = visible_members.order(:member_id)
  end

  def show
  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      redirect_to @member, notice: "Member was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @force_update_retry
      # Bypass optimistic locking for concurrent edit "Save Anyway"
      permitted = member_params.except(:lock_version, :force_update).to_h
      if @member.update_columns(permitted)
        redirect_to @member, notice: "Member was updated (overwrote concurrent changes)."
      else
        render :edit, status: :unprocessable_entity
      end
    elsif @member.update(member_params)
      redirect_to @member, notice: "Member was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.update(deleted_at: Time.current)
    redirect_to members_url, notice: "Member was archived."
  end

  private

  def set_member
    @member = visible_members.find(params[:id])
  end

  # Admins can see every member; members are limited to members linked to their account.
  def visible_members
    scope = Member.where(deleted_at: nil)
    current_user.admin? ? scope : scope.where(user_id: current_user.id)
  end

  def member_params
    params.require(:member).permit(:member_id, :name, :phone_number, :address, :user_id, :lock_version, :force_update)
  end
end
