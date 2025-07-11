class CreateUserDeckProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :user_deck_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :deck, null: false, foreign_key: true
      t.integer :total_sentences
      t.integer :completed_sentences, default: 0
      t.decimal :progress_percentage, precision: 5, scale: 2, default: 0.00
      t.integer :study_time, default: 0

      t.timestamps
    end
    
    add_index :user_deck_progresses, [:user_id, :deck_id], unique: true
    add_index :user_deck_progresses, [:user_id, :progress_percentage]
  end
end
