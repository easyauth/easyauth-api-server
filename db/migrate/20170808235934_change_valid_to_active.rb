class ChangeValidToActive < ActiveRecord::Migration[5.1]
  def change
    rename_column :certificates, :valid, :active
  end
end
