class CreateSentences < ActiveRecord::Migration[8.0]
  def change
    create_table :sentences do |t|
      t.references :deck, null: false, foreign_key: true
      t.text :korean_text
      t.text :english_text
      t.integer :difficulty_level, default: 1
      t.integer :word_count, default: 0

      t.timestamps
    end
  end
end
