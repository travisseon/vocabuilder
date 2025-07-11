class CreateWords < ActiveRecord::Migration[8.0]
  def change
    create_table :words do |t|
      t.references :sentence, null: false, foreign_key: true
      t.string :word
      t.integer :position
      t.boolean :is_distractor, default: false

      t.timestamps
    end
  end
end
