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

ActiveRecord::Schema[8.0].define(version: 2025_07_09_130333) do
  create_table "daily_quotes", force: :cascade do |t|
    t.text "english_text"
    t.text "korean_text"
    t.string "author"
    t.boolean "is_active", default: true
    t.date "display_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display_date"], name: "index_daily_quotes_on_display_date"
    t.index ["is_active"], name: "index_daily_quotes_on_is_active"
  end

  create_table "decks", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "total_sentences", default: 0
    t.integer "difficulty_level", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "learning_records", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "sentence_id", null: false
    t.integer "status", default: 0
    t.integer "attempts_count", default: 0
    t.integer "correct_count", default: 0
    t.boolean "first_attempt_correct", default: false
    t.integer "study_time", default: 0
    t.datetime "last_studied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sentence_id"], name: "index_learning_records_on_sentence_id"
    t.index ["user_id", "last_studied_at"], name: "index_learning_records_on_user_id_and_last_studied_at"
    t.index ["user_id", "sentence_id"], name: "index_learning_records_on_user_id_and_sentence_id", unique: true
    t.index ["user_id", "status"], name: "index_learning_records_on_user_id_and_status"
    t.index ["user_id"], name: "index_learning_records_on_user_id"
  end

  create_table "review_schedules", force: :cascade do |t|
    t.integer "learning_record_id", null: false
    t.date "scheduled_date"
    t.integer "interval_days"
    t.decimal "ease_factor", precision: 3, scale: 2, default: "2.5"
    t.boolean "completed", default: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["learning_record_id"], name: "index_review_schedules_on_learning_record_id"
    t.index ["scheduled_date", "completed"], name: "index_review_schedules_on_scheduled_date_and_completed"
  end

  create_table "sentences", force: :cascade do |t|
    t.integer "deck_id", null: false
    t.text "korean_text"
    t.text "english_text"
    t.integer "difficulty_level", default: 1
    t.integer "word_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_sentences_on_deck_id"
  end

  create_table "user_achievements", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "achievement_type"
    t.text "achievement_data"
    t.datetime "achieved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_type"], name: "index_user_achievements_on_achievement_type"
    t.index ["user_id", "achievement_type"], name: "index_user_achievements_on_user_id_and_achievement_type"
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "user_deck_progresses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "deck_id", null: false
    t.integer "total_sentences"
    t.integer "completed_sentences", default: 0
    t.decimal "progress_percentage", precision: 5, scale: 2, default: "0.0"
    t.integer "study_time", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_user_deck_progresses_on_deck_id"
    t.index ["user_id", "deck_id"], name: "index_user_deck_progresses_on_user_id_and_deck_id", unique: true
    t.index ["user_id", "progress_percentage"], name: "index_user_deck_progresses_on_user_id_and_progress_percentage"
    t.index ["user_id"], name: "index_user_deck_progresses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "nickname"
    t.string "password_digest"
    t.integer "total_study_time", default: 0
    t.integer "streak_days", default: 0
    t.date "last_study_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "verb_explanations", force: :cascade do |t|
    t.integer "sentence_id", null: false
    t.string "verb"
    t.text "explanation"
    t.text "comparison"
    t.text "examples"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sentence_id", "verb"], name: "index_verb_explanations_on_sentence_id_and_verb"
    t.index ["sentence_id"], name: "index_verb_explanations_on_sentence_id"
    t.index ["verb"], name: "index_verb_explanations_on_verb"
  end

  create_table "words", force: :cascade do |t|
    t.integer "sentence_id", null: false
    t.string "word"
    t.integer "position"
    t.boolean "is_distractor", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sentence_id"], name: "index_words_on_sentence_id"
  end

  add_foreign_key "learning_records", "sentences"
  add_foreign_key "learning_records", "users"
  add_foreign_key "review_schedules", "learning_records"
  add_foreign_key "sentences", "decks"
  add_foreign_key "user_achievements", "users"
  add_foreign_key "user_deck_progresses", "decks"
  add_foreign_key "user_deck_progresses", "users"
  add_foreign_key "verb_explanations", "sentences"
  add_foreign_key "words", "sentences"
end
