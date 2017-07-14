class CreateEmailValidations < ActiveRecord::Migration[5.1]
  def change
    create_table :email_validations do |t|
      t.string :code
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
