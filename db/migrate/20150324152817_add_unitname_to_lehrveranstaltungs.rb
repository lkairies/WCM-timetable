class AddUnitnameToLehrveranstaltungs < ActiveRecord::Migration
  def change
    add_column :lehrveranstaltungs, :unit_name, :string
  end
end
