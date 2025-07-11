class CreateReviewSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :review_schedules do |t|
      t.references :learning_record, null: false, foreign_key: true
      t.date :scheduled_date
      t.integer :interval_days
      t.decimal :ease_factor, precision: 3, scale: 2, default: 2.50
      t.boolean :completed, default: false
      t.datetime :completed_at

      t.timestamps
    end
    
    add_index :review_schedules, [:scheduled_date, :completed]
  end
end
