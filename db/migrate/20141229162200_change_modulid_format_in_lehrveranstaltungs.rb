class ChangeModulidFormatInLehrveranstaltungs < ActiveRecord::Migration
  def down
    change_column :lehrveranstaltungs, :modul_id, :integer
  end
  def up
    change_column :lehrveranstaltungs, :modul_id, :string
  end
end
