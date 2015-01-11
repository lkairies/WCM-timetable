class ChangeColumnNameInModuls < ActiveRecord::Migration
  def change
    rename_column :moduls, :nummer, :modul_id
  end
end
