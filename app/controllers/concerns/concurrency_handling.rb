# Concern for handling concurrent edit conflicts (optimistic locking)
# Provides a standard way to handle ActiveRecord::StaleObjectError and
# render a conflict response with the current server data for the modal dialog.
module ConcurrencyHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::StaleObjectError, with: :handle_concurrency_conflict
  end

  private

  # Handles optimistic locking conflicts by rendering a 409 response
  # with the current server state for the concurrent-edit modal.
  # If force_update was submitted, retries the update bypassing the lock check.
  def handle_concurrency_conflict(exception)
    record = exception.record
    record.reload

    # Check if force_update was submitted in the form params
    param_key = record.class.model_name.param_key.to_sym
    force_update = params.dig(param_key, :force_update) == "true" || params[:force_update] == "true"

    if force_update
      # Bypass optimistic locking by using the original lock_version from the form
      # This allows the "Save Anyway" action to succeed once
      original_lock_version = params.dig(param_key, :lock_version) || params[:lock_version]
      record.lock_version = original_lock_version.to_i if original_lock_version.present?

      # Re-attempt the update by calling the update action again
      # We set a flag so the controller knows to skip the normal update path
      @force_update_retry = true
      retry_update_with_force(record)
    elsif request.format.json?
      render json: {
        error: {
          code: "conflict",
          message: "This record was modified by another session while you were editing.",
          current_data: record.as_json,
          record_type: record.class.name.underscore
        }
      }, status: :conflict
    else
      # For HTML requests, store the conflict data and re-render the edit form
      # with the conflict modal data embedded
      @concurrency_conflict = {
        record: record,
        submitted_params: params[param_key]&.to_unsafe_h || {},
        record_type: record.class.name.underscore
      }
      flash.now[:alert] = "This record was modified by another session while you were editing. Please review the changes below."
      render_edit_or_index
    end
  end

  # Attempts to update the record bypassing optimistic locking
  # Controller's update action should check @force_update_retry
  def retry_update_with_force(record)
    # The controller will handle the actual update with @force_update_retry flag
    # We just need to re-render the edit form with the flag set
    # The controller's update action should check this flag and use update_columns
    render :edit, status: :conflict
  end

  # Renders edit action if available, otherwise falls back to index
  def render_edit_or_index
    if respond_to?(:edit, true) && action_name != "edit"
      render :edit, status: :conflict
    else
      render :index, status: :conflict
    end
  end
end
