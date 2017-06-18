class CreateCertificates < ActiveRecord::Migration[5.1]
  def change
    create_table :certificates, id: false do |t|
      t.primary_key :serial
      t.boolean :valid
      t.string :path
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
