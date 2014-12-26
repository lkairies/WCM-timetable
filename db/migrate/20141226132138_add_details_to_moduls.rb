class AddDetailsToModuls < ActiveRecord::Migration
  def change
    add_column :moduls, :art, :string
    add_column :moduls, :titel_englisch, :string
    add_column :moduls, :art_englisch, :string
    add_column :moduls, :empfohlen_fuer, :string
    add_column :moduls, :dauer, :string
    add_column :moduls, :lehrformen, :text
    add_column :moduls, :ziele, :text
    add_column :moduls, :teilnahmevorraussetzungen, :text
    add_column :moduls, :literaturangabe, :text
    add_column :moduls, :vergabe_von_lp, :text
    add_column :moduls, :pruefungsleistungen, :text
  end
end
