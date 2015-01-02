class ChangeFormFormatInLehrveranstaltungs < ActiveRecord::Migration
  def change
    change_column :lehrveranstaltungs, :form, :string
  end
end
