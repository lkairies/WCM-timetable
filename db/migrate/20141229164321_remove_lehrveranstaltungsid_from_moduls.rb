class RemoveLehrveranstaltungsidFromModuls < ActiveRecord::Migration
  def change
    remove_column :moduls, :lehrveranstaltungs_id, :integer
  end
end
