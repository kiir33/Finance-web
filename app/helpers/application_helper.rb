module ApplicationHelper
  # Returns the group treasury account (singleton) for sidebar links
  # Memoized to avoid N+1 queries when rendered multiple times
  def group_treasury_account
    @group_treasury_account ||= GroupAccount.where(deleted_at: nil).first
  end
end
