# Concern for storing request-scoped current_user.
module Current
  extend ActiveSupport::Concern

  class_methods do
    attr_accessor :current_user
  end
end
