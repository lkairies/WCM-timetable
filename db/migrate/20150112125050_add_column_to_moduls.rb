class AddColumnToModuls < ActiveRecord::Migration
  def change
    add_column :moduls, :sws, :text
  end
end
