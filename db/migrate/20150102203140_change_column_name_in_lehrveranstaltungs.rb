class ChangeColumnNameInLehrveranstaltungs < ActiveRecord::Migration
  def change
    rename_column :lehrveranstaltungs, :website, :weblink
  end
end
