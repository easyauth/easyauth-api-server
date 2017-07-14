class AddValidatedToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :validated, :boolean
  end
end
