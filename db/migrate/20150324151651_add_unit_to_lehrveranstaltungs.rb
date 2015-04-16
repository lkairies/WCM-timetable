class AddUnitToLehrveranstaltungs < ActiveRecord::Migration
  def change
    add_column :lehrveranstaltungs, :unit, :string
  end
end
