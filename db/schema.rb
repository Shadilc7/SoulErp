# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_01_175538) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "guardians", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "participant_id", null: false
    t.string "relation"
    t.string "contact_number"
    t.string "occupation"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id"], name: "index_guardians_on_participant_id"
    t.index ["user_id"], name: "index_guardians_on_user_id"
  end

  create_table "institutes", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "description"
    t.string "address"
    t.string "contact_number"
    t.string "email"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "participants", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "section_id"
    t.bigint "institute_id", null: false
    t.date "date_of_birth"
    t.string "education_level"
    t.date "enrollment_date"
    t.integer "status", default: 0
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institute_id"], name: "index_participants_on_institute_id"
    t.index ["section_id"], name: "index_participants_on_section_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "question_set_items", force: :cascade do |t|
    t.bigint "question_set_id", null: false
    t.bigint "question_id", null: false
    t.integer "order_number"
    t.integer "marks_override"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_set_items_on_question_id"
    t.index ["question_set_id"], name: "index_question_set_items_on_question_set_id"
  end

  create_table "question_sets", force: :cascade do |t|
    t.bigint "institute_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "total_marks"
    t.integer "duration_minutes"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institute_id"], name: "index_question_sets_on_institute_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "institute_id", null: false
    t.string "title", null: false
    t.text "description"
    t.integer "question_type", default: 0, null: false
    t.json "options"
    t.integer "correct_option"
    t.text "correct_answer"
    t.integer "marks", default: 1
    t.integer "difficulty_level", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institute_id"], name: "index_questions_on_institute_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "institute_id", null: false
    t.integer "capacity"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.index ["code", "institute_id"], name: "index_sections_on_code_and_institute_id", unique: true
    t.index ["institute_id"], name: "index_sections_on_institute_id"
  end

  create_table "trainers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "institute_id", null: false
    t.string "specialization"
    t.string "qualification"
    t.integer "experience_years"
    t.text "bio"
    t.string "resume"
    t.json "certificates"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institute_id"], name: "index_trainers_on_institute_id"
    t.index ["user_id"], name: "index_trainers_on_user_id"
  end

  create_table "training_programs", force: :cascade do |t|
    t.bigint "institute_id", null: false
    t.bigint "trainer_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "program_type", default: 0, null: false
    t.bigint "section_id"
    t.bigint "participant_id"
    t.integer "status", default: 0
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["institute_id", "program_type"], name: "index_training_programs_on_institute_id_and_program_type"
    t.index ["institute_id"], name: "index_training_programs_on_institute_id"
    t.index ["participant_id"], name: "index_training_programs_on_participant_id"
    t.index ["section_id"], name: "index_training_programs_on_section_id"
    t.index ["trainer_id"], name: "index_training_programs_on_trainer_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username"
    t.integer "role"
    t.integer "institute_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.bigint "section_id"
    t.string "first_name"
    t.string "last_name"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name", "last_name"], name: "index_users_on_first_name_and_last_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["section_id"], name: "index_users_on_section_id"
  end

  add_foreign_key "guardians", "participants"
  add_foreign_key "guardians", "users"
  add_foreign_key "participants", "institutes"
  add_foreign_key "participants", "sections"
  add_foreign_key "participants", "users"
  add_foreign_key "question_set_items", "question_sets"
  add_foreign_key "question_set_items", "questions"
  add_foreign_key "question_sets", "institutes"
  add_foreign_key "questions", "institutes"
  add_foreign_key "sections", "institutes"
  add_foreign_key "trainers", "institutes"
  add_foreign_key "trainers", "users"
  add_foreign_key "training_programs", "institutes"
  add_foreign_key "training_programs", "participants"
  add_foreign_key "training_programs", "sections"
  add_foreign_key "training_programs", "trainers"
  add_foreign_key "users", "sections"
end
