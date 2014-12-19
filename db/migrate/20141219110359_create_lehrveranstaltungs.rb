class CreateLehrveranstaltungs < ActiveRecord::Migration
  def change
    create_table :lehrveranstaltungs do |t|
      t.string :titel
      t.string :dozent
      t.integer :form
      t.text :wochentag
      t.text :zeit_von
      t.text :zeit_bis
      t.text :raum
      t.string :website
      t.references :modul       

      t.timestamps
    end
  end
end
