class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Virtual attribute for bypassing optimistic locking on concurrent edits
  # When set to true, the controller should bypass the lock_version check
  attribute :force_update, :boolean, default: false
end
