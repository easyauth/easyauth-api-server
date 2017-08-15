class AddPasswordAndValidatedToApiKeyUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :api_key_users, :password_digest, :string
  	add_column :api_key_users, :validated, :boolean
  end
end
