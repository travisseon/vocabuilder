class CreateDailyQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_quotes do |t|
      t.text :english_text
      t.text :korean_text
      t.string :author
      t.boolean :is_active, default: true
      t.date :display_date

      t.timestamps
    end
    
    add_index :daily_quotes, :display_date
    add_index :daily_quotes, :is_active
  end
end
