class AddActionToEmailValidations < ActiveRecord::Migration[5.1]
  def change
    add_column :email_validations, :action, :integer
    change_column_null :email_validations, :action, false
  end
end
