class ChangeDataTypeForLehrveranstaltungsForm < ActiveRecord::Migration
  def change
    change_column :lehrveranstaltungs, :form, :integer, :limit => nil
  end
end
