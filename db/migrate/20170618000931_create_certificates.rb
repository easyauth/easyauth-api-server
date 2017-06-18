class CreateCertificates < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates, id: false do |t|
      t.primary_key :serial
      t.boolean :valid, null: false
      t.string :path, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :valid_until, null: false

      t.timestamps
    end
  end
end
