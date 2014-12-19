class CreateModuls < ActiveRecord::Migration
  def change
    create_table :moduls do |t|
      t.string :titel
      t.string :nummer
      t.integer :studiengang
      t.text :beschreibung
      t.integer :form
      t.integer :credits
      t.integer :semesterturnus
      t.string :verantwortlich
      t.text :verwendbarkeit
      t.references :lehrveranstaltungs

      t.timestamps
    end
  end
end
