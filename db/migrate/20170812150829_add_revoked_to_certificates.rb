class AddRevokedToCertificates < ActiveRecord::Migration[5.1]
  def change
  	add_column :certificates, :revoked, :boolean
  end
end
