class CreateApiEmailValidations < ActiveRecord::Migration[5.1]
  def change
    create_table :api_email_validations do |t|
      t.string :code
      t.references :api_key_user, foreign_key: true
      t.string :new_email
      t.integer :action

      t.timestamps
    end
  end
end
