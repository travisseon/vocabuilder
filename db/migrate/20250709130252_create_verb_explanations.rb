class CreateVerbExplanations < ActiveRecord::Migration[8.0]
  def change
    create_table :verb_explanations do |t|
      t.references :sentence, null: false, foreign_key: true
      t.string :verb
      t.text :explanation
      t.text :comparison
      t.text :examples

      t.timestamps
    end
    
    add_index :verb_explanations, [:sentence_id, :verb]
    add_index :verb_explanations, :verb
  end
end
