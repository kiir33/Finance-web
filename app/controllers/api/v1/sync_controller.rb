module Api
  module V1
    class SyncController < ApplicationController
      # Batch upload of client-side changes since last sync.
      def upload
        changes = params[:changes] || []

        results = nil
        ActiveRecord::Base.transaction do
          results = changes.map do |change|
            process_change(change)
          end

          if results.detect { |r| r[:error] == "conflict" } ||
             results.detect { |r| r[:error] == "forbidden" }
            raise ActiveRecord::Rollback
          end
        end

        conflict = results.detect { |r| r[:error] == "conflict" }
        if conflict
          render json: {
            error: { code: "conflict", message: "Record was updated by another session", current: conflict[:current] }
          }, status: :conflict
          return
        end

        forbidden = results.detect { |r| r[:error] == "forbidden" }
        if forbidden
          render json: {
            error: { code: "forbidden", message: "Admin access required" }
          }, status: :forbidden
          return
        end

        # Upsert sync state per device
        device_id = params[:device_id]
        if device_id
          sync_state = SyncState.find_or_initialize_by(device_id: device_id)
          sync_state.last_synced_at = Time.current
          sync_state.save!
        end

        render json: {
          data: { mappings: results.compact },
          meta: { server_time: Time.current.iso8601 }
        }, status: :ok
      end

      # Delta download: all sync_outbox entries changed after `since`.
      def download
        since = params[:since] || 1.year.ago.iso8601

        changes = SyncOutbox.where("changed_at > ?", since).order(:changed_at)

        render json: {
          data: {
            changes: changes.map do |change|
              {
                record_type: change.record_type,
                record_id: change.record_id,
                public_id: change.public_id,
                changed_at: change.changed_at.iso8601,
                deleted: change.deleted
              }
            end
          },
          meta: { server_time: Time.current.iso8601 }
        }, status: :ok
      end

      private

      def process_change(change)
        record_type = change[:record_type]
        op = change[:op]
        payload = change[:payload]
        local_temp_id = change[:local_temp_id]
        public_id = change[:public_id]

        case record_type
        when "client"
          process_client_change(op, payload, local_temp_id, public_id)
        when "loan"
          process_loan_change(op, payload, local_temp_id, public_id)
        when "savings_account"
          process_savings_account_change(op, payload, local_temp_id, public_id)
        when "system_config"
          process_system_config_change(op, payload, public_id)
        else
          { local_temp_id: local_temp_id, error: "unknown_record_type" }
        end
      end

      def process_client_change(op, payload, local_temp_id, public_id)
        case op
        when "create"
          client = Client.new(payload.permit(:client_id, :name, :phone_number, :address, :user_id))
          client.public_id = public_id if public_id.present?
          if client.save
            { local_temp_id: local_temp_id, public_id: client.public_id }
          else
            { local_temp_id: local_temp_id, error: client.errors.full_messages }
          end
        when "update"
          client = Client.find_by(public_id: public_id)
          unless client
            return { public_id: public_id, error: "not_found" }
          end
          if stale?(client, payload[:lock_version])
            return { public_id: public_id, error: "conflict", current: client_slice(client) }
          end
          if client.update(payload.permit(:client_id, :name, :phone_number, :address, :user_id))
            { public_id: client.public_id }
          else
            { public_id: public_id, error: client.errors.full_messages }
          end
        when "delete"
          client = Client.find_by(public_id: public_id)
          if client
            client.update(deleted_at: Time.current)
            { public_id: public_id }
          else
            { public_id: public_id, error: "not_found" }
          end
        end
      end

      def process_loan_change(op, payload, local_temp_id, public_id)
        case op
        when "create"
          loan = Loan.new(payload.permit(:client_id, :public_id, :lock_version))
          if loan.save
            { local_temp_id: local_temp_id, public_id: loan.public_id }
          else
            { local_temp_id: local_temp_id, error: loan.errors.full_messages }
          end
        when "update"
          loan = Loan.find_by(public_id: public_id)
          unless loan
            return { public_id: public_id, error: "not_found" }
          end
          if stale?(loan, payload[:lock_version])
            return { public_id: public_id, error: "conflict", current: loan_slice(loan) }
          end
          if loan.update(payload.permit(:client_id, :lock_version))
            { public_id: loan.public_id }
          else
            { public_id: public_id, error: loan.errors.full_messages }
          end
        when "delete"
          loan = Loan.find_by(public_id: public_id)
          if loan
            loan.update(deleted_at: Time.current)
            { public_id: public_id }
          else
            { public_id: public_id, error: "not_found" }
          end
        end
      end

      def process_savings_account_change(op, payload, local_temp_id, public_id)
        case op
        when "create"
          account = SavingsAccount.new(payload.permit(:client_id, :public_id, :lock_version))
          if account.save
            { local_temp_id: local_temp_id, public_id: account.public_id }
          else
            { local_temp_id: local_temp_id, error: account.errors.full_messages }
          end
        when "update"
          account = SavingsAccount.find_by(public_id: public_id)
          unless account
            return { public_id: public_id, error: "not_found" }
          end
          if stale?(account, payload[:lock_version])
            return { public_id: public_id, error: "conflict", current: account_slice(account) }
          end
          if account.update(payload.permit(:client_id, :lock_version))
            { public_id: account.public_id }
          else
            { public_id: public_id, error: account.errors.full_messages }
          end
        when "delete"
          account = SavingsAccount.find_by(public_id: public_id)
          if account
            account.update(deleted_at: Time.current)
            { public_id: public_id }
          else
            { public_id: public_id, error: "not_found" }
          end
        end
      end

      def process_system_config_change(op, payload, public_id)
        return { error: "forbidden" } unless current_user&.admin?

        case op
        when "create"
          config = SystemConfig.new(payload.permit(:config_key, :config_value, :config_type, :description))
          if config.save
            { config_key: config.config_key }
          else
            { config_key: payload[:config_key], error: config.errors.full_messages }
          end
        when "update"
          config = SystemConfig.find_by(config_key: public_id)
          unless config
            return { config_key: public_id, error: "not_found" }
          end
          if stale?(config, payload[:lock_version])
            return { config_key: public_id, error: "conflict", current: config_slice(config) }
          end
          if config.update(payload.permit(:config_value, :config_type, :description))
            { config_key: config.config_key }
          else
            { config_key: public_id, error: config.errors.full_messages }
          end
        when "delete"
          config = SystemConfig.find_by(config_key: public_id)
          if config
            config.destroy
            { config_key: public_id }
          else
            { config_key: public_id, error: "not_found" }
          end
        end
      end

      def stale?(record, client_lock_version)
        return false if client_lock_version.nil?
        record.lock_version != client_lock_version.to_i
      end

      def client_slice(client)
        { id: client.public_id, client_id: client.client_id, name: client.name,
          lock_version: client.lock_version, updated_at: client.updated_at, deleted_at: client.deleted_at }
      end

      def loan_slice(loan)
        { id: loan.public_id, client_id: loan.client_id, lock_version: loan.lock_version,
          updated_at: loan.updated_at, deleted_at: loan.deleted_at }
      end

      def account_slice(account)
        { id: account.public_id, client_id: account.client_id, lock_version: account.lock_version,
          updated_at: account.updated_at, deleted_at: account.deleted_at }
      end

      def config_slice(config)
        { key: config.config_key, value: config.config_value, type: config.config_type,
          lock_version: config.lock_version, updated_at: config.updated_at }
      end
    end
  end
end
