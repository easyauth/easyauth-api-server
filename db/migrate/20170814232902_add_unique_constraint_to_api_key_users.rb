class AddUniqueConstraintToApiKeyUsers < ActiveRecord::Migration[5.1]
  def change
  	add_index :api_key_users, :email, unique: true
  end
end
