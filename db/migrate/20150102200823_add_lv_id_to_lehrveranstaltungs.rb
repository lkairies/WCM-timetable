class AddLvIdToLehrveranstaltungs < ActiveRecord::Migration
  def change
    add_column :lehrveranstaltungs, :lv_id, :string
  end
end
