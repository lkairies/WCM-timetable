class AddIndexToSemesters < ActiveRecord::Migration
  def change
    add_index :semesters, :semester_id, unique: true
  end
end
