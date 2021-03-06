# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150726103832) do

  create_table "lehrveranstaltungs", force: true do |t|
    t.string   "titel"
    t.text     "dozent"
    t.integer  "form"
    t.text     "wochentag"
    t.text     "zeit_von"
    t.text     "zeit_bis"
    t.text     "raum"
    t.string   "weblink"
    t.string   "modul_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lv_id"
    t.string   "semester"
    t.string   "unit"
    t.string   "unit_name"
  end

  create_table "moduls", force: true do |t|
    t.string   "titel"
    t.string   "modul_id"
    t.integer  "studiengang"
    t.text     "beschreibung"
    t.integer  "form"
    t.integer  "credits"
    t.integer  "semesterturnus"
    t.string   "verantwortlich"
    t.text     "verwendbarkeit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "art"
    t.string   "titel_englisch"
    t.string   "art_englisch"
    t.string   "empfohlen_fuer"
    t.string   "dauer"
    t.text     "lehrformen"
    t.text     "ziele"
    t.text     "teilnahmevorraussetzungen"
    t.text     "literaturangabe"
    t.text     "vergabe_von_lp"
    t.text     "pruefungsleistungen"
    t.text     "sws"
  end

  create_table "semesters", force: true do |t|
    t.string   "semester_id"
    t.date     "begin"
    t.date     "end"
    t.date     "lvbegin"
    t.date     "lvend"
    t.text     "vorlesungstage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "semesters", ["semester_id"], name: "index_semesters_on_semester_id", unique: true

  create_table "studiengang_moduls", force: true do |t|
    t.string   "studiengang"
    t.string   "modul_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
