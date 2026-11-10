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
  def handle_concurrency_conflict(exception)
    record = exception.record
    record.reload

    if request.format.json?
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
        submitted_params: params[record.class.name.underscore.to_sym]&.to_unsafe_h || {},
        record_type: record.class.name.underscore
      }
      flash.now[:alert] = "This record was modified by another session while you were editing. Please review the changes below."
      render :edit, status: :conflict
    end
  end
end