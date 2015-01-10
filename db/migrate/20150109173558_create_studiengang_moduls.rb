class CreateStudiengangModuls < ActiveRecord::Migration
  def change
    create_table :studiengang_moduls do |t|
      t.string :studiengang
      t.string :modul_id

      t.timestamps
    end
  end
end
