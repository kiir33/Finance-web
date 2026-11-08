module Api
  module V1
    class SyncController < ApplicationController
      def upload
        changes = params[:changes] || []

        results = changes.map do |change|
          process_change(change)
        end

        # Update sync state
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
        client_updated_at = change[:client_updated_at]

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
          client = Client.new(payload.permit(:client_id, :name, :phone_number, :address))
          client.public_id = public_id if public_id.present?
          if client.save
            log_sync_outbox("client", client.id, client.public_id, false)
            { local_temp_id: local_temp_id, public_id: client.public_id }
          else
            { local_temp_id: local_temp_id, error: client.errors.full_messages }
          end
        when "update"
          client = Client.find_by(public_id: public_id)
          if client && client.update(payload.permit(:client_id, :name, :phone_number, :address))
            log_sync_outbox("client", client.id, client.public_id, false)
            { public_id: client.public_id }
          else
            { public_id: public_id, error: "not_found" }
          end
        when "delete"
          client = Client.find_by(public_id: public_id)
          if client
            client.update(deleted_at: Time.current)
            log_sync_outbox("client", client.id, client.public_id, true)
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
            log_sync_outbox("loan", loan.id, loan.public_id, false)
            { local_temp_id: local_temp_id, public_id: loan.public_id }
          else
            { local_temp_id: local_temp_id, error: loan.errors.full_messages }
          end
        when "update"
          loan = Loan.find_by(public_id: public_id)
          if loan && loan.update(payload.permit(:lock_version))
            log_sync_outbox("loan", loan.id, loan.public_id, false)
            { public_id: loan.public_id }
          else
            { public_id: public_id, error: "not_found_or_conflict" }
          end
        when "delete"
          loan = Loan.find_by(public_id: public_id)
          if loan
            loan.update(deleted_at: Time.current)
            log_sync_outbox("loan", loan.id, loan.public_id, true)
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
            log_sync_outbox("savings_account", account.id, account.public_id, false)
            { local_temp_id: local_temp_id, public_id: account.public_id }
          else
            { local_temp_id: local_temp_id, error: account.errors.full_messages }
          end
        when "update"
          account = SavingsAccount.find_by(public_id: public_id)
          if account && account.update(payload.permit(:lock_version))
            log_sync_outbox("savings_account", account.id, account.public_id, false)
            { public_id: account.public_id }
          else
            { public_id: public_id, error: "not_found_or_conflict" }
          end
        when "delete"
          account = SavingsAccount.find_by(public_id: public_id)
          if account
            account.update(deleted_at: Time.current)
            log_sync_outbox("savings_account", account.id, account.public_id, true)
            { public_id: public_id }
          else
            { public_id: public_id, error: "not_found" }
          end
        end
      end

      def process_system_config_change(op, payload, public_id)
        admin_only!

        case op
        when "create"
          config = SystemConfig.new(payload.permit(:config_key, :config_value, :config_type, :description))
          if config.save
            log_sync_outbox("system_config", config.id, config.config_key, false)
            { config_key: config.config_key }
          else
            { config_key: payload[:config_key], error: config.errors.full_messages }
          end
        when "update"
          config = SystemConfig.find_by(config_key: public_id)
          if config && config.update(payload.permit(:config_value, :config_type, :description))
            log_sync_outbox("system_config", config.id, config.config_key, false)
            { config_key: config.config_key }
          else
            { config_key: public_id, error: "not_found_or_conflict" }
          end
        when "delete"
          config = SystemConfig.find_by(config_key: public_id)
          if config
            config.destroy
            log_sync_outbox("system_config", config.id, config.config_key, true)
            { config_key: public_id }
          else
            { config_key: public_id, error: "not_found" }
          end
        end
      end

      def log_sync_outbox(record_type, record_id, public_id, deleted)
        SyncOutbox.create!(
          record_type: record_type,
          record_id: record_id.to_s,
          public_id: public_id.to_s,
          changed_at: Time.current,
          deleted: deleted
        )
      end
    end
  end
end
