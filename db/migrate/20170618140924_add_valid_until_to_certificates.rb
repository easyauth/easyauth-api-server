class AddValidUntilToCertificates < ActiveRecord::Migration[5.1]
  def change
    add_column :certificates, :valid_until, :datetime
  end
end
