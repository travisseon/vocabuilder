class CreateDecks < ActiveRecord::Migration[8.0]
  def change
    create_table :decks do |t|
      t.string :name
      t.text :description
      t.integer :total_sentences, default: 0
      t.integer :difficulty_level, default: 1

      t.timestamps
    end
  end
end
