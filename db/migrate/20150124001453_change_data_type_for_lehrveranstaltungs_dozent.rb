class ChangeDataTypeForLehrveranstaltungsDozent < ActiveRecord::Migration
  def change
    change_column :lehrveranstaltungs, :dozent, :text, :limit => nil
  end
end
