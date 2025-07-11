class CreateLearningRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :learning_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :sentence, null: false, foreign_key: true
      t.integer :status, default: 0
      t.integer :attempts_count, default: 0
      t.integer :correct_count, default: 0
      t.boolean :first_attempt_correct, default: false
      t.integer :study_time, default: 0
      t.datetime :last_studied_at

      t.timestamps
    end
    
    add_index :learning_records, [:user_id, :sentence_id], unique: true
    add_index :learning_records, [:user_id, :status]
    add_index :learning_records, [:user_id, :last_studied_at]
  end
end
