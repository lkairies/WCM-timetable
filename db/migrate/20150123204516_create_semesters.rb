class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.string :semester_id
      t.date :begin
      t.date :end
      t.date :lvbegin
      t.date :lvend
      t.text :vorlesungstage

      t.timestamps
    end
  end
end
