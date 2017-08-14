class CreateApiKeyUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :api_key_users do |t|
      t.string :email
      t.string :public_key
      t.string :secret_key

      t.timestamps
    end
  end
end
