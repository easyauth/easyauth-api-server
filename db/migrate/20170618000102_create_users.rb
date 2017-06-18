class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :name, null: false
      t.string :password, null: false

      t.timestamps

      t.index :email_address, unique: true
    end
  end
end
