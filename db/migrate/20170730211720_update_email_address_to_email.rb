class UpdateEmailAddressToEmail < ActiveRecord::Migration[5.1]
  def change
  	rename_column :users, :email_address, :email
  end
end
