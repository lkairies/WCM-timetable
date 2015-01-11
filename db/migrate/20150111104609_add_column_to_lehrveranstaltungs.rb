class AddColumnToLehrveranstaltungs < ActiveRecord::Migration
  def change
    add_column :lehrveranstaltungs, :semester, :string
  end
end
