class AddNewEmailToEmailValidations < ActiveRecord::Migration[5.1]
  def change
    add_column :email_validations, :new_email, :string
  end
end
