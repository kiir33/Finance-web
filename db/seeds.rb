# Seed data for development
# Create a default admin user
admin = User.find_or_create_by!(email: "admin@financeapp.local") do |user|
  user.password = "admin123"
  user.role = :admin
end

puts "Created admin user: #{admin.email} (role: #{admin.role})"

# Create a default member user
member = User.find_or_create_by!(email: "member@financeapp.local") do |user|
  user.password = "member123"
  user.role = :member
end

puts "Created member user: #{member.email} (role: #{member.role})"

# Seed system configs
SystemConfig.find_or_create_by!(config_key: "savings_interest_rate") do |config|
  config.config_value = "5.0"
  config.config_type = "savings"
  config.description = "Annual interest rate for savings accounts (percentage)"
end

SystemConfig.find_or_create_by!(config_key: "loan_max_amount") do |config|
  config.config_value = "100000"
  config.config_type = "loan"
  config.description = "Maximum loan amount allowed per member"
end

SystemConfig.find_or_create_by!(config_key: "savings_cap_percentage") do |config|
  config.config_value = "80"
  config.config_type = "savings"
  config.description = "Maximum loan amount as percentage of savings (80% cap)"
end

puts "Seeded system configs"

# Create a group account
GroupAccount.find_or_create_by!(public_id: SecureRandom.uuid) do |account|
  account.cash_balance = 0
  account.bank_balance = 0
end

puts "Seeded group account"
